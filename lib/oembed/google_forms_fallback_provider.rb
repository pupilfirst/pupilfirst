module Oembed
  class GoogleFormsFallbackProvider < BaseFallbackProvider
    def self.domains
      [/docs\.google\.com/]
    end

    def self.paths
      [
        /^\/forms\/.*\/viewform/
      ]
    end

    def resource_url
      if @resource_url.include?('embedded=true')
        @resource_url
      else
        full_path = @resource_url.split('?').first
        full_path + '?embedded=true'
      end
    end
  end
end
