module Vimeo
  class ApiService
    def initialize(current_school)
      @current_school = current_school
    end

    def create_video(size)
      response = create_video_resource(size)
      raise "Encountered error with code #{response[:error_code]} when trying to create a Vimeo video." if response[:error_code].present?
      response
    end

    def add_allowed_domain_to_video(domain, video_id)
      path = "/videos/#{video_id}/privacy/domains/#{domain}"
      put(path, {})
    end

    private 

    def create_video_resource(size)
      data = {
        upload: {
          approach: 'tus',
          size: size
        },
        privacy: {
          embed: 'whitelist'
        }
      }
      
      post('/me/videos', data)
    end

    def put(path, data)
      uri = URI(full_url(path))
      request = Net::HTTP::Put.new(uri)
      request.body = data.to_json
      execute(uri, request)
    end

    def post(path, data)
      uri = URI(full_url(path))
      request = Net::HTTP::Post.new(uri)
      request.body = data.to_json
      execute(uri, request)
    end

    def execute(uri, request)
      add_headers(request)

      net_http = Net::HTTP.new(uri.hostname, uri.port)
      net_http.use_ssl = true
      raw_response = net_http.request(request)

      if raw_response.body.present?
        JSON.parse(raw_response.body)
      else
        {}
      end.with_indifferent_access
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
