module Users
  # Service responsible validating reset password token for user
  class ValidateResetTokenService
    # @param token [String] Token received via link.
    def initialize(token)
      @token = token
    end

    # @return [User, nil] User with the specified token, or nil.
    def authenticate
      if @token.present? && valid_request?
        user
      end
    end

    private

    def user
      @user ||= User.find_by(reset_password_token: @token)
    end

    def valid_request?
      return false if user.blank?

      return false if user.reset_password_sent_at.blank? && time_limitation?

      if time_limitation?
        valid_time?
      else
        true
      end
    end

    def valid_time?
      time_since_last_mail = Time.zone.now - user.reset_password_sent_at
      time_since_last_mail < time_limit_minutes
    end

    def time_limitation?
      ENV.fetch('RESET_PASSWORD_TOKEN_TIME_LIMIT') { '' }.present?
    end

    def time_limit_minutes
      env_var = ENV.fetch('RESET_PASSWORD_TOKEN_TIME_LIMIT') { '' } 
      if env_var.present?
        env_var.to_i.minutes
      else
        0.minutes
      end
    end
  end
end
