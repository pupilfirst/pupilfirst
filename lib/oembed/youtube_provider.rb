module Oembed
  class YoutubeProvider < BaseProvider
    def self.domains
      [
        /youtube\.com/,
        /youtu\.be/
      ]
    end

    def url
      "https://www.youtube.com/oembed?format=json&url="
    end
  end
end
