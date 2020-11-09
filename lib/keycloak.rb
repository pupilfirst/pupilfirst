module Keycloak
  CONFIG = {
    client_id: ENV['KEYCLOAK_CLIENT_ID'],
    client_secret: ENV['KEYCLOAK_CLIENT_SECRET'],
    realm: ENV['KEYCLOAK_REALM'],
    domain: ENV['KEYCLOAK_SITE'],
  }.freeze

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
        raise 'Failed to fetch Keycloak\'s openid config'
      end
    end

    def token
      openid_config['token_endpoint'] 
    end

    def admin_users
      uri = URI(domain)
      uri.path = "/auth/admin/realms/#{realm}/users"
      uri
    end
  end

  class ServiceAccount
    def endpoints
      @endpoints ||= Endpoints.new
    end

    def access_token
      @access_token ||= fetch_tokens[:access_token]
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
        @refresh_token = tokens['refresh_token']
        {access_token: tokens['access_token'], refresh_token: tokens['refresh_token']}
      else
        raise 'Failed to sign-in as Keycloak\'s service account'
      end
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
        MultiJson.load(res.body).first
      else
        raise "Failed to find user by email: #{email}"
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
        raise 'Failed to create_user'
      end
    end

    def update_user_password(email, password)
      user_rep = {
        credentials: [{
          type: "password",
          temporary: false,
          value: password
        }]
      }
      headers = {
        'Authorization' => "Bearer #{service_account.access_token}",
        'Content-Type' => 'application/json'
      }
      user = fetch_user(email)
      user_update_uri = endpoints.admin_users
      user_update_uri.join(user['id'])
      res = Faraday.put(user_update_uri, user_rep.to_json, headers)
      if res.status == 200
        MultiJson.load(res.body)
      else
        raise 'Failed to create_user'
      end
    end
  end
end
