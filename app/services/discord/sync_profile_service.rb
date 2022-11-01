module Discord
  class SyncProfileService
    def initialize(user)
      @user = user
      @configuration = user.school.configuration['discord']
    end

    def execute
      return unless @user.discord_user_id.present? && @configuration.present?

      role_ids =
        [
          @user.cohorts.pluck(:discord_role_ids),
          @configuration['default_role_ids']
        ].flatten - [nil]

      return if role_ids.empty?

      Discordrb::API::Server.update_member(
        "Bot #{@configuration['bot_token']}",
        @configuration['server_id'],
        @user.discord_user_id,
        roles: role_ids,
        nick: @user.name
      )
    end
  end
end
