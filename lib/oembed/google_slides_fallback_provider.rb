module Oembed
  class GoogleSlidesFallbackProvider < BaseFallbackProvider
    def self.domains
      [/docs\.google\.com/]
    end

    def self.paths
      [
        /^\/presentation\/.*\/pub/
      ]
    end

    def resource_url
      # Replace '/pub' with '/embed'.
      @resource_url.gsub('/pub', '/embed')
    end
  end
end
