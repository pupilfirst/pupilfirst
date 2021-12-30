module Users
  # Service responsible authenticating users with tokens.
  class AuthenticationService
    # @param token [String] Token received via link.
    def initialize(school, token)
      @school = school
      @token = token
    end

    # @return [User, nil] User with the specified token, or nil.
    def authenticate
      if @token.present? && user.present? && valid_request?
        # Clear the token from user.
        user.update!(login_token_digest: nil)
        user
      end
    end

    private

    def user
      login_token = Digest::SHA2.base64digest(@token)
      @user ||= @school.users.find_by(login_token_digest: login_token)
    end

    def valid_request?
      return false if user.blank?

      return false if user.login_mail_sent_at.blank?

      time_since_last_mail = Time.zone.now - user.login_mail_sent_at
      time_since_last_mail < time_limit_minutes
    end

    def time_limit_minutes
      time_limit = ENV.fetch('LOGIN_TOKEN_TIME_LIMIT', '30').to_i
      time_limit.positive? ? time_limit.minutes : 30.minutes
    end
  end
end
