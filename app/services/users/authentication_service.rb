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
      if @token.present? && user.present?
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
  end
end
