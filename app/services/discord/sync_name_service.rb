module Discord
  class SyncNameService
    def initialize(user)
      @user = user
    end

    def execute
      return unless @user.discord_user_id.present?

      Discordrb::API::Server.update_member(
        "Bot #{ENV['DISCORD_BOT_TOKEN']}",
        ENV['DISCORD_SERVER_ID'],
        @user.discord_user_id,
        nick: @user.name
      )
    end
  end
end
