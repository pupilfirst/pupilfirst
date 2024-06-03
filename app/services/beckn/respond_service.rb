require "net/http"
require "json"

module Beckn
  class RespondService
    def initialize(payload)
      @payload = payload
    end

    def execute(action, response)
      data = { context: build_context(action), **response }

      response = send_post_request(end_point(action), data)
      handle_response(response)
    end

    private

    def end_point(action)
      Rails.application.secrets.beckn[:bpp_client_uri] + "/" + action
    end

    def build_context(action)
      context = @payload["context"].dup
      context.delete("action")
      context.merge!(
        bpp_id: Rails.application.secrets.beckn[:bpp_id],
        bpp_uri: Rails.application.secrets.beckn[:bpp_uri],
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
  end
end
