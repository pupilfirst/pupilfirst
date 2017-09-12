module Founders
  # Raised if the founder belongs to a startup that is Level 1+.
  CannotAcceptInvitationException = Class.new(StandardError)

  # This service can be used by founders in Level 0 to accept invitation to another startup.
  class AcceptInvitationService
    include Loggable

    def initialize(founder)
      @founder = founder
      @original_startup = @founder.startup
    end

    def execute
      raise CannotAcceptInvitationException if @original_startup&.level&.number&.positive?

      Founder.transaction do
        accept_invitation
        clean_up
      end
    end

    private

    def accept_invitation
      @founder.update!(
        startup: @founder.invited_startup,
        invited_startup: nil,
        invitation_token: nil
      )

      # Set confirmed_at if it's not already set.
      Users::ConfirmationService.new(@founder.user).execute
    end

    def clean_up
      return if @original_startup.blank?

      if @original_startup.team_lead == @founder
        @original_startup.update!(team_lead: nil)
      end

      if @original_startup.reload.founders.any?
        preserve_startup
      else
        delete_startup
      end
    end

    def preserve_startup
      # Make another founder the team lead if this founder was the admin.
      if @original_startup.team_lead.blank?
        another_founder = @original_startup.founders.where.not(id: @founder.id).first
        Founders::BecomeTeamLeadService.new(another_founder).execute
      end

      # Delete timeline event associated with cofounder addition target, if number of founders has dropped to one.
      if @original_startup.billing_founders_count == 1
        cofounder_addition_target.timeline_events.find_by(startup: @original_startup)&.destroy!
      end
    end

    def delete_startup
      # There are no founders, so cancel all invitations, if any.
      if @original_startup.invited_founders.any?
        @original_startup.invited_founders.each do |invited_founder|
          invited_founder.update!(
            invited_startup: nil,
            invitation_token: nil
          )
        end
      end

      refund_and_unlink_payment(@original_startup.payments.last) if @original_startup.payments.any?

      # And delete the startup.
      @original_startup.reload.destroy!
    end

    # Refund credited payments, and unlink it from startup.
    def refund_and_unlink_payment(payment)
      if payment.credited?
        if payment.refundable?
          log "Attempting to refund payment from Founder ##{@founder.id} - #{@founder.name}..."
          Payments::RefundService.new(payment).execute
        else
          log "Founder ##{@founder.id} - #{@founder.name} has a payment which cannot be refunded (more than a week old)."
          AdmissionsMailer.automatic_refund_failed(payment).deliver_later
        end
      end

      # Unlinking the payment from the startup allows the startup to be destroyed.
      payment.startup = nil
      payment.save!
    end

    def cofounder_addition_target
      @cofounder_addition_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_COFOUNDER_ADDITION)
    end
  end
end
