module Oembed
  class VimeoProvider < BaseProvider
    def url
      "https://vimeo.com/api/oembed.json?url="
    end
  end
end
