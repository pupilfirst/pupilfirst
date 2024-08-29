module Users
  # Service responsible validating reset password token for user
  class ValidateResetTokenService
    # @param token [String] Token received via link.
    def initialize(token)
      @token = token
    end

    # @return [User, nil] User with the specified token, or nil.
    def authenticate
      user if @token.present? && valid_request?
    end

    private

    def user
      reset_token = Digest::SHA2.base64digest(@token)
      @user ||= User.find_by(reset_password_token: reset_token)
    end

    def valid_request?
      return false if user.blank?

      return false if user.reset_password_sent_at.blank?

      time_since_last_mail = Time.zone.now - user.reset_password_sent_at
      time_since_last_mail < time_limit_minutes
    end

    def time_limit_minutes
      time_limit = ENV.fetch("RESET_PASSWORD_TOKEN_TIME_LIMIT", "15").to_i
      time_limit.positive? ? time_limit.minutes : 15.minutes
    end
  end
end
