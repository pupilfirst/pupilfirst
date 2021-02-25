module Keycloak
  class FakeClient
    def initialize
      reset!
    end

    def reset!
      @users = {}
    end

    def fetch_user(email)
     user_by_email(email) or raise FailedRequestError.new "Failed to find user by email: #{email}"
    end

    def create_user(email, first_name, last_name)
      user = user_by_email(email)
      raise FailedRequestError.new 'Failed to create_user' if user
      @users[email] = {
        username: email,
        email: email,
        firstName: first_name,
        lastName: last_name,
        enabled: true,
        active: true,
        credentials: {},
      }.with_indifferent_access
      nil
    end

    def set_user_password(email, password)
      user = user_by_email(email)
      raise FailedRequestError.new 'Failed to set user password' unless user
      user[:credentials] = {
        type: "password",
        temporary: false,
        value: password
      }
      nil
    end

    def user_info(access_token)
      user = user_by_token(access_token)
      raise FailedRequestError.new 'Failed to set user password' unless user
      user
    end

    def user_signed_in?(access_token)
      user = user_by_token(access_token)
      user && user[:active]
    end

    def user_token(uname_email, password)
      user = user_by_email(uname_email)
      valid = user && user.dig(:credentials, :value) == password
      raise FailedRequestError.new 'Failed to set user password' unless valid
      user[:token] = SecureRandom.uuid
    end

    def user_sign_out(refresh_token)
      user = user_by_token(refresh_token)
      raise FailedRequestError.new 'Failed to sign out user' unless user
      @users.delete(user[:email])
      true
    end

    private
    def user_by_token(token)
      @users.values.find{|user| user[:token] == token}
    end

    def user_by_email(email)
      @users[email]
    end
  end
end
