module Keycloak
  RT_COOKIE_KEY = :keycloak_refresh_token
  CONFIG = {
    client_id: ENV['KEYCLOAK_CLIENT_ID'],
    client_secret: ENV['KEYCLOAK_CLIENT_SECRET'],
    realm: ENV['KEYCLOAK_REALM'],
    domain: ENV['KEYCLOAK_SITE'],
  }.freeze

  class FailedRequestError < StandardError; end

  class Endpoints
    attr_reader :domain, :realm, :client_id, :client_secret
    def initialize
      @domain = CONFIG[:domain]
      @realm = CONFIG[:realm]
      @client_id = CONFIG[:client_id]
      @client_id = CONFIG[:client_id]
    end

    def openid_config_uri
      openid_config_uri = URI(domain)
      openid_config_uri.path = "/auth/realms/#{realm}/.well-known/openid-configuration"
      openid_config_uri
    end

    def openid_config
      return @openid_config if @openid_config

      res = Faraday.get(openid_config_uri.to_s)
      if res.status == 200
        @openid_config = MultiJson.load(res.body)
      else
        raise FailedRequestError.new 'Failed to fetch Keycloak\'s openid config'
      end
    end

    def token
      openid_config['token_endpoint']
    end

    def token_introspection
      openid_config['token_introspection_endpoint']
    end

    def end_session
      openid_config['end_session_endpoint']
    end

    def admin_users
      uri = URI(domain)
      uri.path = "/auth/admin/realms/#{realm}/users"
      uri
    end
  end

  class ServiceAccount
    attr_reader :access_token, :refresh_token

    def initialize
      fetch_tokens
    end

    def endpoints
      @endpoints ||= Endpoints.new
    end

    def access_token
      if signed_in?
        @access_token
      else
        refresh_access_token
        @access_token
      end
    end

    def fetch_tokens
      params = {
        'client_id' => CONFIG[:client_id],
        'client_secret' => CONFIG[:client_secret],
        'grant_type' => 'client_credentials',
      }
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
      res = Faraday.post(endpoints.token, params, headers)

      if res.status == 200
        tokens = MultiJson.load(res.body)
        @access_token = tokens['access_token']
        @refresh_token = tokens['refresh_token']
      else
        raise FailedRequestError.new 'Failed to sign-in as Keycloak\'s service account'
      end
    end

    def refresh_access_token
      params = {
        'client_id' => CONFIG[:client_id],
        'client_secret' => CONFIG[:client_secret],
        'refresh_token' => refresh_token,
        'grant_type' => 'refresh_token',
      }
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
      res = Faraday.post(endpoints.token, params, headers)

      if res.status == 200
        tokens = MultiJson.load(res.body)
        @access_token = tokens['access_token']
        @refresh_token = tokens['refresh_token']
      else
        raise FailedRequestError.new 'Failed to refresh Keycloak\'s service account access_token'
      end
    end

    def signed_in?
      Client.new.user_signed_in?(@access_token)
    end
  end

  class Client
    def endpoints
      @endpoints ||= Endpoints.new
    end

    def service_account
      @service_account ||= ServiceAccount.new
    end

    def fetch_user(email)
      uri = endpoints.admin_users
      uri.query = "search=#{email}"
      headers = { 'Authorization' => "Bearer #{service_account.access_token}" }
      res = Faraday.get(uri, nil, headers)
      if res.status == 200
        user = MultiJson.load(res.body).first
        user.presence || raise(FailedRequestError.new "Failed to find user by email: #{email}")
      else
        raise FailedRequestError.new "Failed to find user by email: #{email}"
      end
    end

    def create_user(email, first_name, last_name)
      user_rep = {
        username: email,
        email: email,
        firstName: first_name,
        lastName: last_name,
        enabled: true
      }
      headers = {
        'Authorization' => "Bearer #{service_account.access_token}",
        'Content-Type' => 'application/json'
      }
      res = Faraday.post(endpoints.admin_users, user_rep.to_json, headers)
      if res.status == 201
        nil
      elsif res.status == 409
        body = MultiJson.load(res.body)
        Rails.logger.info(body['errorMessage'])
        nil
      else
        raise FailedRequestError.new 'Failed to create_user'
      end
    end

    def set_user_password(email, password)
      creds_rep = {
        type: "password",
        temporary: false,
        value: password
      }
      headers = {
        'Authorization' => "Bearer #{service_account.access_token}",
        'Content-Type' => 'application/json'
      }
      user = fetch_user(email)
      reset_password_uri = endpoints.admin_users
      reset_password_uri.path = reset_password_uri.path.concat("/#{user['id']}", '/reset-password')
      res = Faraday.put(reset_password_uri, creds_rep.to_json, headers)
      if res.status == 204
        nil
      else
        raise FailedRequestError.new 'Failed to set user password'
      end
    end

    def user_info(access_token)
      client_id = CONFIG[:client_id]
      client_secret = CONFIG[:client_secret]
      auth = Base64.strict_encode64("#{client_id}:#{client_secret}")
      headers = {
        'Authorization' => "Basic #{auth}",
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
      payload = { 'token' => access_token }
      res = Faraday.post(endpoints.token_introspection, payload, headers)
      if res.status == 200
        MultiJson.load(res.body)
      else
        raise FailedRequestError.new 'Failed to fetch user_info'
      end
    end

    def user_signed_in?(access_token)
      user_info(access_token)['active']
    end

    def user_token(uname_email, password)
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
      payload = {
        'client_id' => CONFIG[:client_id],
        'client_secret' => CONFIG[:client_secret],
        'username' => uname_email,
        'password' => password,
        'grant_type' => 'password'
      }
      res = Faraday.post(endpoints.token, payload, headers)
      if res.status == 200
        MultiJson.load(res.body)
      else
        raise FailedRequestError.new 'Failed to set user password'
      end
    end

    def user_sign_out(refresh_token)
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
      payload = {
        'client_id' => CONFIG[:client_id],
        'client_secret' => CONFIG[:client_secret],
        'refresh_token' => refresh_token
      }

      res = Faraday.post(endpoints.end_session, payload, headers)
      if res.status == 204
        true
      else
        raise FailedRequestError.new 'Failed to sign out user'
      end
    end
  end

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
