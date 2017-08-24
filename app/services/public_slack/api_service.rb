module PublicSlack
  class ApiService
    class << self
      attr_writer :mock

      def mock?
        defined?(@mock) ? @mock : Rails.env.test? || Rails.env.development?
      end
    end

    def initialize(token: Rails.application.secrets.slack.dig(:app, :oauth_token))
      @token = token
    end

    def get(path, params)
      api_url = endpoint(path, params)
      response = RestClient.get(api_url)
      parsed_response = JSON.parse(response)
      return parsed_response if parsed_response['ok']
      raise PublicSlack::OperationFailureException, "Response from Slack API indicates failure: '#{response}'"
    rescue JSON::ParserError
      raise PublicSlack::ParseFailureException, "Failed to parse response as JSON: '#{response}'"
    rescue RestClient::Exception => e
      raise PublicSlack::TransportFailureException, "HTTP failure (#{e}) when calling #{api_url}"
    end

    private

    def endpoint(path, params)
      final_params = params.merge(token: @token)
      "#{URI.join('https://slack.com/api/', path)}?#{final_params.to_query}"
    end
  end
end
