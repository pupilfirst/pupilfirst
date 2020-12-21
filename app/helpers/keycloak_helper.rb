require 'keycloak'

module KeycloakHelper
  def create_keycloak_user(email, name)
    names = name.split(' ')
    first_name = names.pop
    last_name = names.join(' ') || ''
    Rails.configuration.keycloak_client.create_user(email, first_name, last_name)
  end
end
