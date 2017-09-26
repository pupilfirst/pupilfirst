class Instamojo
  # Instamojo::BaseService should be used to inherit basic methods to contact Instamojo's API.
  #
  # Use specific services if they exist, or write them if you encounter missing functionality.
  class BaseService
    def post(path, data = {})
      request(:post, path, data)
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    private

    def request(type, path, data_or_params = {})
      uri = URI(full_url(path))

      request = if type == :get
        uri.query = URI.encode_www_form(params) if data_or_params.present?
        Net::HTTP::Get.new(uri)
      elsif type == :post
        new_request = Net::HTTP::Post.new(uri)
        new_request.set_form_data(data_or_params) if data_or_params.present?
        new_request
      end

      request['X-Api-Key'] = Rails.application.secrets.instamojo_api_key
      request['X-Auth-Token'] = Rails.application.secrets.instamojo_auth_token

      begin
        raw_response = http(uri).request(request)
      rescue SocketError, Net::HTTPServerError => e
        raise Instamojo::TransportFailureException, "Failed because of #{e.class} with message: #{e.message}"
      end

      parse(raw_response)
    end

    def parse(raw_response)
      response = begin
        JSON.parse(raw_response.body).with_indifferent_access
      rescue JSON::ParserError
        raise Instamojo::CouldNotParseResponseException, "Failed to parse the response from Instamojo API as JSON: #{raw_response.body}"
      end

      unless response[:success]
        raise Instamojo::RequestFailedException, "Response from Instamojo API was valid JSON, but the success key was not set to true: #{raw_response.body}"
      end

      response
    end

    def http(uri)
      net_http = Net::HTTP.new(uri.hostname, uri.port)
      net_http.use_ssl = true
      net_http
    end

    def full_url(path)
      url = [base_url, path].join('/')
      url += '/' unless url.ends_with?('/')
      url
    end

    def base_url
      Rails.application.secrets.instamojo_url
    end
  end
end
