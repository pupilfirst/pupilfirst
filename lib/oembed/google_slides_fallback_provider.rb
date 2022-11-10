module Oembed
  class GoogleSlidesFallbackProvider < BaseFallbackProvider
    def self.domains
      [/docs\.google\.com/]
    end

    def self.paths
      [
        /^\/presentation\/.*\/edit/
      ]
    end

    def resource_url
      @resource_url
    end
  end
end
