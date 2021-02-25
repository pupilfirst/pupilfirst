module Keycloak
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
end
