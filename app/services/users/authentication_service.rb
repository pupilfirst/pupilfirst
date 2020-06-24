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
        user.update!(login_token: nil)
        user
      end
    end

    private

    def user
      @user ||= @school.users.find_by(login_token: @token)
    end
  end
end
