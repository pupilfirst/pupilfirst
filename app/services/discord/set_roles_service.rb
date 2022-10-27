module Discord
  class SetRolesService
    def initialize(user)
      @user = user
    end

    def execute(roles_ids)
      return unless @user.discord_user_id.present?

      Discordrb::API::Server.update_member(
        "Bot #{ENV['DISCORD_BOT_TOKEN']}",
        ENV['DISCORD_SERVER_ID'],
        @user.discord_user_id,
        roles: roles_ids
      )
    end
  end
end
