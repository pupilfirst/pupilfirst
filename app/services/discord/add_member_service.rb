module Discord
  class AddMemberService
    def initialize(user)
      @user = user
    end

    def execute(discord_user_id, tag, access_token)
      return false unless configuration.configured? && @user.present?

      Discordrb::API::Server.add_member(
        "Bot #{configuration.bot_token}",
        configuration.server_id,
        discord_user_id,
        access_token
      )

      @user.update!(discord_user_id: discord_user_id, discord_tag: tag)

      Discord::SyncProfileJob.perform_later(@user)

      return true
    rescue Discordrb::Errors::UnknownUser
      Rails.logger.error "Unknown user #{discord_user_id}"
      return false
    rescue Discordrb::Errors::NoPermission
      Rails.logger.error "No permission to Add member #{discord_user_id}"
      return false
    rescue RestClient::BadRequest => e
      Rails
        .logger.error "Bad request with discord_user_id: #{discord_user_id}; #{e.response.body}"
      return false
    end

    def configuration
      @configuration ||= Schools::Configuration::Discord.new(@user.school)
    end
  end
end
