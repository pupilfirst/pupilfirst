module Oembed
  class ScribehowFallbackProvider < BaseFallbackProvider
    def self.domains
      [/scribehow\.com/]
    end

    def self.paths
      [%r{^/embed/.*}]
    end
  end
end
