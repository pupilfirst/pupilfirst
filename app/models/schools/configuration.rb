module Schools
  class Configuration
    class Discord
      attr_accessor :bot_token, :server_id, :bot_user_id

      def initialize(school)
        @discord = school.configuration["discord"].presence || {}
        @bot_token = @discord["bot_token"]
        @server_id = @discord["server_id"]
        @bot_user_id = @discord["bot_user_id"]
      end

      def configured?
        @bot_token.present? && @server_id.present? && @bot_user_id.present?
      end
    end

    class EmailSenderSignature
      attr_accessor :name, :email, :confirmed_at

      def initialize(school)
        @ess = school.configuration["email_sender_signature"].presence || {}
        @name = @ess["name"]
        @email = @ess["email"]
        @confirmed_at = @ess["confirmed_at"]
      end

      def configured?
        @name.present? && @email.present? && @confirmed_at.present?
      end
    end

    class Vimeo
      attr_accessor :account_type, :access_token

      def initialize(school)
        @vimeo = school.configuration["vimeo"].presence || {}
        @account_type = @vimeo["account_type"]
        @access_token = @vimeo["access_token"]
      end

      def configured?
        @account_type.present? && @access_token.present?
      end
    end

    class Github
      attr_accessor :access_token, :organization_id, :default_team_id

      def initialize(school)
        @github = school.configuration["github"].presence || {}
        @access_token = @github["access_token"]
        @organization_id = @github["organization_id"]
        @default_team_id = @github["default_team_id"]
      end

      def configured?
        @access_token.present? && @organization_id.present? &&
          @default_team_id.present?
      end
    end

    def initialize(school)
      @school = school
    end

    def disable_primary_domain_redirection?
      @school.configuration["disable_primary_domain_redirection"]
    end

    def delete_inactive_users_after
      @school.configuration["delete_inactive_users_after"]
    end

    def standing_enabled?
      !!@school.configuration["enable_standing"]
    end

    def default_currency
      @school.configuration["default_currency"].presence || "INR"
    end
  end
end
