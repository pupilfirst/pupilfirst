module Oembed
  class BaseProvider
    def initialize(resource_url)
      @resource_url = resource_url
    end

    def url
      raise 'Not implemented in BaseProvider'
    end

    def embed_code
      # Hit the endpoint and get raw response.
      # response = RestClient.do_something(url)

      # Parse the reponse as JSON.
      parse(response)

      # Return the 'html' key from the response.
      parsed_response['html']
    end
  end
end
