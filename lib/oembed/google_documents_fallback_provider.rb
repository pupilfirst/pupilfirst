module Oembed
  class GoogleDocumentsFallbackProvider < BaseFallbackProvider
    def self.domains
      [/docs\.google\.com/]
    end

    def self.paths
      [
        /^\/document\/.*\/pub$/
      ]
    end

    def resource_url
      if @resource_url.include?('embedded=true')
        @resource_url
      else
        @resource_url + '?embedded=true'
      end
    end
  end
end

