module Schools
  class DiscordConfigurationForm < Reform::Form
    attr_accessor :current_school

    property :server_id
    property :bot_user_id
    property :bot_token

    validate :validate_server_id
    validate :validate_bot_user_id
    validate :validate_bot_token

    def save
      config = current_school.configuration.fetch("discord", {})

      config["server_id"] = server_id
      config["bot_user_id"] = bot_user_id
      config["bot_token"] = bot_token.presence || config.fetch("bot_token")

      current_school.update!(configuration: current_school.configuration.merge("discord" => config))
    end

    private
    def validate_server_id
      return if server_id.blank?

      unless server_id.match?(/^\d+\z/)
        errors.add(:server_id, "is not a valid Discord Server ID.")
      end
    end

    def validate_bot_user_id
      return if bot_user_id.blank?

      unless bot_user_id.match?(/^\d+\z/)
        errors.add(:bot_user_id, "is not a valid Discord Bot User ID.")
      end
    end

    def validate_bot_token
      return if bot_token.blank?

      unless bot_token.match?(/^[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+$/)
        errors.add(:bot_token, "is not a valid Discord Bot Token.")
      end
    end
  end
end
