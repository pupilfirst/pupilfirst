module Discord
  class SyncNameService
    def initialize(user)
      @user = user
    end

    def execute
      return if @user.discord_user_id.blank? || !configuration.configured?

      Discordrb::API::Server.update_member(
        "Bot #{configuration.bot_token}",
        configuration.server_id,
        @user.discord_user_id,
        nick: nick_name
      )
    rescue Discordrb::Errors::UnknownMember
      Rails.logger.error "Unknown member #{@user.discord_user_id}"
      @user.update!(discord_user_id: nil)
    rescue Discordrb::Errors::NoPermission
      Rails
        .logger.error "No permission to update member #{@user.discord_user_id}"
    rescue RestClient::BadRequest => e
      Rails
        .logger.error "Bad request with discord_user_id: #{@user.discord_user_id}; #{e.response.body}"
    end

    def nick_name
      return @user.name if @user.name.length <= 32
      @user.name[0..28] + '...'
    end

    def configuration
      @configuration ||= Schools::Configuration::Discord.new(@user.school)
    end
  end
end
