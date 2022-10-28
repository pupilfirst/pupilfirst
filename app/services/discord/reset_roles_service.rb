module Discord
  class ResetRolesService
    def initialize(user)
      @user = user
    end

    def execute
      return unless @user.discord_user_id.present?

      role_ids = @user.cohorts.pluck(:discord_role_ids).flatten

      return if role_ids.empty?

      Discordrb::API::Server.update_member(
        "Bot #{ENV['DISCORD_BOT_TOKEN']}",
        ENV['DISCORD_SERVER_ID'],
        @user.discord_user_id,
        roles: role_ids
      )
    end
  end
end
