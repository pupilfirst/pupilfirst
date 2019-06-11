module Oembed
  class YoutubeProvider < BaseProvider
    def self.url
      "https://www.youtube.com/oembed?format=json&url="
    end
  end
end
