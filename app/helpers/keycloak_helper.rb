module KeycloakHelper
  def self.openid_config
    site = keycloak_oauth_config['client_options']['site']
    realm = keycloak_oauth_config['client_options']['realm']
    res = Faraday.get "#{site}/auth/realms/#{realm}/.well-known/openid-configuration"
    if (res.status == 200)
      MultiJson.load(res.body)
    else
      raise 'failed to fetch config'
    end
  end

  def self.end_session_endpoint
    openid_config['end_session_endpoint']
  end

  def self.sign_out(refresh_token)
    config = keycloak_oauth_config
    params = {
      'client_id' => config['client_id'],
      'client_secret' => config['client_secret'],
      'refresh_token' => refresh_token
    }
    res = Faraday.post(end_session_endpoint, params, { 'Content-Type' => 'application/x-www-form-urlencoded' })
    if (res.status == 204)
      nil
    else
      raise 'failed to sign_out'
    end
  end

  def self.keycloak_oauth_config
    Devise.omniauth_configs[:keycloak_openid].strategy
  end
end
