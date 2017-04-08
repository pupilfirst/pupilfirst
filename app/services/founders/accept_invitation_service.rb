module Founders
  # Raised if the founder belongs to a startup that is Level 1+.
  CannotAcceptInvitationException = Class.new(StandardError)

  # This service can be used by founders in Level 0 to accept invitation to another startup.
  class AcceptInvitationService
    def initialize(founder)
      @founder = founder
    end

    def execute
      raise CannotAcceptInvitationException if @founder.startup&.level&.number&.positive?

      @founder.update!(
        startup: @founder.invited_startup,
        invited_startup: nil,
        invitation_token: nil
      )
    end
  end
end
