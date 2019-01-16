module Cloudflare
  class ApiService
    def initialize(path)
      @path = path
    end

    def post(data)
      uri = URI(full_url(@path), data.to_json, 'Content-Type' => 'application/json')
      request = Net::HTTP::Post.new(uri)
      execute(uri, request)
    end

    def get(params = {})
      uri = URI(full_url(@path))
      uri.query = URI.encode_www_form(params) if params.present?
      request = Net::HTTP::Get.new(uri)
      execute(uri, request)
    end

    private

    def execute(uri, request)
      add_headers(request)

      net_http = Net::HTTP.new(uri.hostname, uri.port)
      net_http.use_ssl = true
      raw_response = net_http.request(request)

      JSON.parse(raw_response.body).with_indifferent_access
    end

    def add_headers(request)
      request['X-Auth-Email'] = Rails.application.secrets.cloudflare[:email]
      request['X-Auth-Key'] = Rails.application.secrets.cloudflare[:key]
    end

    def full_url(path)
      url = [base_url, path].join('/')
      url += '/' unless url.ends_with?('/')
      url
    end

    def base_url
      @base_url ||= 'https://api.cloudflare.com/client/v4/'
    end
  end
end
