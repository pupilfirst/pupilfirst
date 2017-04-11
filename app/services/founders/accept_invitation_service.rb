module Founders
  # Raised if the founder belongs to a startup that is Level 1+.
  CannotAcceptInvitationException = Class.new(StandardError)

  # This service can be used by founders in Level 0 to accept invitation to another startup.
  class AcceptInvitationService
    def initialize(founder)
      @founder = founder
    end

    def execute
      raise CannotAcceptInvitationException if original_startup&.level&.number&.positive?

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
        invitation_token: nil,
        startup_admin: false
      )
    end

    def clean_up
      return if original_startup.blank?

      if original_startup.founders.any?
        # Make another founder the team lead.
        another_founder = original_startup.founders.where.not(id: @founder.id).first
        Founders::BecomeTeamLeadService.new(another_founder).execute
      else
        # There are no founders, so cancel all invitations, if any.
        if original_startup.invited_founders.any?
          original_startup.invited_founders.each do |invited_founder|
            invited_founder.update!(
              invited_startup: nil,
              invitation_token: nil
            )
          end
        end

        # And delete the startup.
        original_startup.destroy!
      end
    end

    def original_startup
      # Memoize nil startup as well.
      return @original_startup if defined?(@original_startup)
      @original_startup = @founder.startup
    end
  end
end
