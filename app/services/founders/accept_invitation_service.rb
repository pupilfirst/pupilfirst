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

      # And delete the startup.
      @original_startup.reload.destroy!
    end

    def cofounder_addition_target
      @cofounder_addition_target ||= Target.find_by(key: Target::KEY_COFOUNDER_ADDITION)
    end
  end
end
