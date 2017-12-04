module Zoom
  class ApiService
    # @param method [String] Zoom API method to call
    def get(method)
      uri = URI(base_url + method)
      net_http = Net::HTTP.new(uri.hostname, uri.port)
      net_http.use_ssl = true

      # add authorization header
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{token}"

      # TODO: Handle failures
      JSON.parse(net_http.request(request).body)
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

    def base_url
      @base_url ||= 'https://api.zoom.us/v2/'
    end
  end
end
