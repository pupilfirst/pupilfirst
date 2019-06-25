module Oembed
  class YoutubeProvider < BaseProvider
    def url
      "https://www.youtube.com/oembed?format=json&url="
    end
  end
end
