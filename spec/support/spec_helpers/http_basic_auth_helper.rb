# Helper for managing HTTP Basic Auth when making requests.
module HttpBasicAuthHelper
  def request_spec_headers(user, password)
    {
      'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
    }
  end
end
