module Oembed
  class ScribehowFallbackProvider < BaseFallbackProvider
    def self.domains
      [/scribehow\.com/]
    end

    def self.paths
      [%r{^/embed/.*}, %r{^/shared/.*}]
    end

    def resource_url
      @resource_url.gsub("/shared", "/embed")
    end
  end
end
