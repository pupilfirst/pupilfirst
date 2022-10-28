module Discord
  class ClearRolesService
    def initialize(user, discord_user_id)
      @user = user
      @discord_user_id = discord_user_id
      @configuration = user.school.configuration['discord']
    end

    def execute
      return unless @discord_user_id.present? && @configuration.present?

      Discordrb::API::Server.update_member(
        "Bot #{@configuration['bot_token']}",
        @configuration['server_id'],
        @discord_user_id,
        roles: []
      )
    end
  end
end
