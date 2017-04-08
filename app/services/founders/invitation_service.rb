module Founders
  CannotBeInvitedException = Class.new(StandardError)

  # Used to invite new founders to a startup in Level 0.
  class InvitationService
    def initialize(startup, founder_attributes)
      @startup = startup
      @attributes = founder_attributes.merge(invited_startup: startup)
    end

    def execute
      founder = Founder.with_email(@attributes[:email]).first

      if founder.present?
        if founder.startup.present?
          raise CannotBeInvitedException if founder.startup == @startup || founder.startup.level.number.positive?
        end

        # Regenerate invitation token to invalidate previous invite.
        founder.regenerate_invitation_token
      else
        # Find or create user.
        user = User.with_email(@attributes[:email]).first
        user = User.create!(email: @attributes[:email]) if user.blank?

        # Create the founder.
        founder = Founder.create!(@attributes.merge(user: user))
      end

      # Set the new invited startup.
      founder.update!(invited_startup: @startup)

      FounderMailer.invite(founder, @startup).deliver_later
    end
  end
end
