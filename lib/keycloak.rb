module Keycloak
  RT_COOKIE_KEY = :keycloak_refresh_token
  CONFIG = {
    client_id: ENV['KEYCLOAK_CLIENT_ID'],
    client_secret: ENV['KEYCLOAK_CLIENT_SECRET'],
    realm: ENV['KEYCLOAK_REALM'],
    domain: ENV['KEYCLOAK_SITE'],
  }.freeze

  class FailedRequestError < StandardError; end
end

require_relative 'keycloak/client'
require_relative 'keycloak/endpoints'
require_relative 'keycloak/fake_client'
require_relative 'keycloak/service_account'
