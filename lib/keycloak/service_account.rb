module Keycloak
  class ServiceAccount
    class FailedFetchTokensError < FailedRequestError; end
    class FailedRefreshAccessTokenError < FailedRequestError; end
    attr_reader :refresh_token

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
        begin
          refresh_access_token
        rescue FailedRefreshAccessTokenError
          fetch_tokens
        end
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
        raise FailedFetchTokensError.new "Failed to sign-in as Keycloak\'s service account - #{res.body}"
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
        raise FailedRefreshAccessTokenError.new "Failed to refresh Keycloak\'s service account access_token - #{res.body}"
      end
    end

    def signed_in?
      Client.new.user_signed_in?(@access_token)
    end
  end
end
