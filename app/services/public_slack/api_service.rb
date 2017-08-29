module PublicSlack
  class ApiService
    class << self
      attr_writer :mock

      def mock?
        defined?(@mock) ? @mock : Rails.env.test? || Rails.env.development?
      end
    end

    # @param token [String] Token to use with the API call, if any.
    def initialize(token: nil)
      @token = token
    end

    # @param method [String] Slack API method to call
    # @param params [Hash] Parameters to pass with the method call
    def get(method, params: {})
      api_url = endpoint(method, params)
      response = RestClient.get(api_url)
      parsed_response = JSON.parse(response)

      return parsed_response if parsed_response['ok']

      exception = PublicSlack::OperationFailureException.new(
        "Response from Slack API indicates failure: '#{response}'",
        parsed_response
      )

      raise exception
    rescue JSON::ParserError
      raise PublicSlack::ParseFailureException, "Failed to parse response as JSON: '#{response}'"
    rescue RestClient::Exception => e
      raise PublicSlack::TransportFailureException, "HTTP failure (#{e}) when calling #{api_url}"
    end

    private

    def endpoint(method, params)
      # Add the token to query if one is available.
      query_params = @token.present? ? params.merge(token: @token) : params

      "#{URI.join('https://slack.com/api/', method)}?#{query_params.to_query}"
    end
  end
end
