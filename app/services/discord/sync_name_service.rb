module Discord
  class SyncNameService
    def initialize(user)
      @user = user
    end

    def execute
      return if @user.discord_user_id.blank? || configuration.blank?

      Discordrb::API::Server.update_member(
        "Bot #{configuration['bot_token']}",
        configuration['server_id'],
        @user.discord_user_id,
        nick: @user.name
      )
    rescue Discordrb::Errors::NoPermission
      Rails
        .logger.error "No permission to update member #{@user.discord_user_id}"
    rescue RestClient::BadRequest
      Rails
        .logger.error "Bad request with discord_user_id: #{@user.discord_user_id}"
    end

    def configuration
      @configuration ||= Schools::Configuration.new(@user.school).discord
    end
  end
end
