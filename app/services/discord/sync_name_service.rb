module Discord
  class SyncNameService
    def initialize(user)
      @user = user
      @configuration = user.school.configuration['discord']
    end

    def execute
      return if @user.discord_user_id.blank?

      Discordrb::API::Server.update_member(
        "Bot #{@configuration['bot_token']}",
        @configuration['server_id'],
        @user.discord_user_id,
        nick: @user.name
      )
    end
  end
end
