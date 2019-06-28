module Oembed
  class SlideshareProvider < BaseProvider
    def self.domains
      [/slideshare\.net/]
    end

    def url
      "https://www.slideshare.net/api/oembed/2?format=json&url="
    end
  end
end
