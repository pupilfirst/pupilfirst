module Oembed
  class BaseFallbackProvider
    attr_reader :resource_url

    def self.domains
      raise 'Not implemented in BaseFallbackProvider'
    end

    def self.paths
      raise 'Not implemented in BaseFallbackProvider'
    end

    def initialize(resource_url)
      @resource_url = resource_url
    end

    def embed_code
      "<iframe src='#{resource_url}' frameborder='0' width='960' height='572' allowfullscreen='true' mozallowfullscreen='true' webkitallowfullscreen='true'></iframe>"
    end
  end
end
