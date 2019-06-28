module Oembed
  class VimeoProvider < BaseProvider
    def self.domains
      [/vimeo\.com/]
    end

    def url
      "https://vimeo.com/api/oembed.json?url="
    end
  end
end
