# Helper for managing token-based authentication when making requests.
module TokenAuthHelper
  def request_spec_headers(user)
    user.regenerate_api_token

    {
      'Authorization' => "Bearer #{user.api_token}",
      'Accept' => 'application/json'
    }
  end
end
