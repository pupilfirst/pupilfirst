module Founders
  CannotBeInvitedException = Class.new(StandardError)

  # Used to invite new founders to a startup in Level 0.
  #
  # TODO: Founders::InvitationService should be updated to record invitation on the User entry, instead of creating a Founder entry, which MUST be linked to a Startup.
  class InvitationService
    def initialize(startup, founder_attributes)
      @startup = startup
      @attributes = founder_attributes.merge(invited_startup: startup)
    end

    def execute
      founder = Founder.with_email(@attributes[:email])

      if founder.present?
        if founder.startup.present?
          raise CannotBeInvitedException if founder.startup == @startup || founder.startup.level.number.positive?
        end

        # Regenerate invitation token to invalidate previous invite.
        founder.regenerate_invitation_token
      else
        # Find or create user.
        user = User.with_email(@attributes[:email])
        user = User.create!(email: @attributes[:email]) if user.blank?

        # Create a blank startup.
        # TODO: This is potentially risky. See TODO above class definition.
        startup = Startup.create!(
          product_name: Startups::ProductNameGeneratorService.new.fun_name,
          level: @attributes[:invited_startup].level
        )

        # Create the founder.
        founder = Founder.create!(@attributes.merge(user: user, startup: startup))
      end

      # Set the new invited startup.
      founder.update!(invited_startup: @startup)

      FounderMailer.invite(founder, @startup).deliver_later
    end
  end
end
