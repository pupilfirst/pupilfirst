module Vimeo
  class ApiService
    def initialize(path, current_school)
      @path = path
      @current_school = current_school
    end

    def post(data)
      uri = URI(full_url(@path))
      request = Net::HTTP::Post.new(uri)
      request.body = data.to_json
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
      request['Authorization'] = "bearer #{access_token}"
      request['Accept'] = 'application/vnd.vimeo.*+json;version=3.4'
    end

    def full_url(path)
      url = "#{base_url}#{path}"
      url += '/' unless url.ends_with?('/')
      url
    end

    def access_token
      @current_school.configuration['vimeo_access_token'] || 
        Rails.application.secrets.vimeo_access_token
    end

    def base_url
      @base_url ||= 'https://api.vimeo.com'
    end
  end
end
