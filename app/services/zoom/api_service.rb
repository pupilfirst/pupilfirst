module Zoom
  class ApiService
    # @param method [String] Zoom API method to call
    def get(method)
      url = base_url + method
      response = RestClient.get(url, authorization_header)
      JSON.parse(response)
    end

    # @param method [String] Zoom API method to call
    # @param payload [Hash] The payload to be sent in the request body as JSON.
    def post(method, payload = {})
      url = base_url + method
      headers = authorization_header.merge(content_type: :json)
      RestClient.post(url, payload.to_json, headers)
    end

    # @param method [String] Zoom API method to call
    # @param payload [Hash] The payload to be sent in the request body as JSON.
    def patch(method, payload = {})
      url = base_url + method
      headers = authorization_header.merge(content_type: :json)
      RestClient.patch(url, payload.to_json, headers)
    end

    private

    # returns a JWT which expires 5 minutes from invocation.
    def token
      payload = {
        iss: Rails.application.secrets.zoom[:api_key],
        exp: 5.minutes.from_now.to_i
      }
      secret = Rails.application.secrets.zoom[:api_secret]

      JWT.encode(payload, secret, 'HS256')
    end

    def authorization_header
      { Authorization: "Bearer #{token}" }
    end

    def base_url
      @base_url ||= 'https://api.zoom.us/v2/'
    end
  end
end
