module Founders
  # Raised if the founder belongs to a startup that is Level 1+.
  CannotAcceptInvitationException = Class.new(StandardError)

  # This service can be used by founders in Level 0 to accept invitation to another startup.
  class AcceptInvitationService
    include Loggable

    def initialize(founder)
      @founder = founder
    end

    def execute
      raise CannotAcceptInvitationException if original_startup&.level&.number&.positive?

      Founder.transaction do
        accept_invitation
        complete_cofounder_addition_target
        clean_up
      end
    end

    private

    # Complete the target asking founder to add co-founders.
    def complete_cofounder_addition_target
      if cofounder_addition_target.status(@founder) != Targets::StatusService::STATUS_COMPLETE
        Admissions::CompleteTargetService.new(@founder, Target::KEY_ADMISSIONS_COFOUNDER_ADDITION).execute
      end
    end

    def accept_invitation
      @founder.update!(
        startup: @founder.invited_startup,
        invited_startup: nil,
        invitation_token: nil,
        startup_admin: false
      )

      # Set confirmed_at if it's not already set.
      Users::ConfirmationService.new(user).execute
    end

    def clean_up
      return if original_startup.blank?

      if original_startup.founders.any?
        preserve_startup
      else
        delete_startup
      end
    end

    def preserve_startup
      # Make another founder the team lead if this founder was the admin.
      if original_startup.admin.blank?
        another_founder = original_startup.founders.where.not(id: @founder.id).first
        Founders::BecomeTeamLeadService.new(another_founder).execute
      end

      # Delete timeline event associated with cofounder addition target, if number of founders has dropped to one.
      if original_startup.founders.count == 1
        cofounder_addition_target.timeline_events.find_by(startup: original_startup)&.destroy!
      end
    end

    def delete_startup
      # There are no founders, so cancel all invitations, if any.
      if original_startup.invited_founders.any?
        original_startup.invited_founders.each do |invited_founder|
          invited_founder.update!(
            invited_startup: nil,
            invitation_token: nil
          )
        end
      end

      # Refund successful payments.
      if original_startup.payment.present?
        if original_startup.payment.refundable?
          log "Attempting to refund payment from Founder ##{@founder.id} - #{@founder.name}..."
          Payments::RefundService.new(original_startup.payment).execute
        else
          log "Founder ##{@founder.id} - #{@founder.name} has a payment which cannot be refunded (more than a week old)."
        end
      end

      # And delete the startup.
      original_startup.reload.destroy!
    end

    def cofounder_addition_target
      @cofounder_addition_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_COFOUNDER_ADDITION)
    end

    def original_startup
      # Memoize nil startup as well.
      return @original_startup if defined?(@original_startup)
      @original_startup = @founder.startup
    end
  end
end
