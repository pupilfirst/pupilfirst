require 'keycloak'

module KeycloakHelper
  RT_COOKIE_KEY = :keycloak_refresh_token
  def create_keycloak_user(email, name)
    names = name.split(' ')
    first_name = names.pop
    last_name = names.join(' ') || ''
    keycloak_client.create_user(email, first_name, last_name)
  end

  def keycloak_client
    @keycloak_client ||= Keycloak::Client.new
  end
end
