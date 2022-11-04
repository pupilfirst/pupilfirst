module Discord
  class AddMemberService
    def initialize(user)
      @user = user
    end

    def execute(discord_user_id, access_token)
      return unless configuration.configured? && @user.present?

      role_ids =
        [
          @user.cohorts.pluck(:discord_role_ids),
          configuration.default_role_ids
        ].flatten - [nil]

      Discordrb::API::Server.add_member(
        "Bot #{configuration.bot_token}",
        configuration.server_id,
        discord_user_id,
        access_token
      )

      @user.update!(discord_user_id: discord_user_id)
      Discord::SyncProfileJob.perform_later(@user)

      return true
    rescue Discordrb::Errors::UnknownUser
      Rails.logger.error "Unknown user #{discord_user_id}"
      return false
    rescue Discordrb::Errors::NoPermission
      Rails.logger.error "No permission to Add member #{discord_user_id}"
      return false
    rescue RestClient::BadRequest
      Rails.logger.error "Bad request with discord_user_id: #{discord_user_id}"
      return false
    end

    def configuration
      @configuration ||= Schools::Configuration::Discord.new(@user.school)
    end
  end
end
