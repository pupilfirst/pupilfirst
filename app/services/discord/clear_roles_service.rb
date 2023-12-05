module Discord
  class ClearRolesService
    def initialize(discord_user_id, configuration)
      @discord_user_id = discord_user_id
      @configuration = configuration
    end

    def execute
      return unless @configuration.configured?

      begin
        Discordrb::API::Server.update_member(
          "Bot #{@configuration.bot_token}",
          @configuration.server_id,
          @discord_user_id,
          roles: []
        )
      rescue Discordrb::Errors::UnknownMember
        Rails.logger.error "Unknown member #{@discord_user_id}"
      rescue Discordrb::Errors::NoPermission
        Rails.logger.error "No permission to update member #{@discord_user_id}"
      rescue RestClient::BadRequest => e
        Rails.logger.error "Bad request with discord_user_id: #{@discord_user_id}; #{e.response.body}"
      end
    end
  end
end
