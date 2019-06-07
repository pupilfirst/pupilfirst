module Oembed
  class SlideshareProvider < BaseProvider
    def url
      "https://www.slideshare.net/api/oembed/2?url="
    end
  end
end
