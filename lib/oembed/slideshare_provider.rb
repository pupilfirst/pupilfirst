module Oembed
  class SlideshareProvider < BaseProvider
    def self.url
      "https://www.slideshare.net/api/oembed/2?format=json&url="
    end
  end
end
