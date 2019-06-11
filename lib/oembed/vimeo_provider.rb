module Oembed
  class YoutubeProvider < BaseProvider
    def self.url
      "https://vimeo.com/api/oembed.json?url="
    end
  end
end
