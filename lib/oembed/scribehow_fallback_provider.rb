module Oembed
  class ScribehowFallbackProvider < BaseFallbackProvider
    def self.domains
      [/scribehow\.com/]
    end

    def self.paths
      [%r{^/embed/.*}, %r{^/shared/.*}]
    end

    def resource_url
     @resource_url.gsub("scribehow.com/shared", "scribehow.com/embed")
    end
  end
end
