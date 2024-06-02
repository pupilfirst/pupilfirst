require "net/http"
require "json"

module Beckn
  class RespondService
    def initialize(school, payload)
      @school = school
      @payload = payload
    end

    def execute(action, response)
      data = { context: build_context(action), **response }

      response = send_post_request(end_point(action), data)
      handle_response(response)
    end

    private

    def end_point(action)
      config.bpp_client_uri + "/" + action
    end

    def build_context(action)
      context = @payload["context"].dup
      context.delete("action")
      context.merge!(
        bpp_id: config.bpp_id,
        bpp_uri: config.bpp_uri,
        action: action
      )

      context
    end

    def send_post_request(url, payload)
      uri = URI(url)
      request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      request.body = payload.to_json

      Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
    end

    def handle_response(response)
      if response.is_a?(Net::HTTPSuccess)
        puts "Request was successful."
        puts response.body
      else
        puts "Request failed: #{response.code} #{response.message}"
      end
      response
    end

    def config
      @config ||= Schools::Configuration::Beckn.new(@school)
    end
  end
end
