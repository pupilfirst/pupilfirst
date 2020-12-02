module Oembed
  class BaseProvider
    def initialize(resource_url)
      @resource_url = resource_url
    end

    def self.domains
      raise 'Not implemented in BaseProvider'
    end

    def self.paths
      [/.*/]
    end

    def url
      raise 'Not implemented in BaseProvider'
    end

    def embed_code
      # Hit the endpoint and get raw response.
      response = RestClient.get(url + @resource_url)

      # Parse the reponse as JSON.
      parsed_response = JSON.parse(response)

      # Return the 'html' key from the response.
      parsed_response['html']
    rescue => e
      Rails.logger.error "Oembed::BaseProvider resolve failed: #{e.message}"

      if e.backtrace.respond_to?(:join)
        Rails.logger.error(e.backtrace.join("\n"))
      end

      nil
    end
  end
end
