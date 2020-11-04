module Oembed
  class GoogleSlideProvider < BaseProvider
    def initialize(resource_url)
      embed_resource_url = resource_url.gsub('pub', 'embed')
      @resource_url = embed_resource_url
    end

    def self.domains
      [/docs\.google\.com/]
    end

    def embed_code
      "<iframe src=\"#{@resource_url}\" frameborder=\"0\" width=\"960\" height=\"569\" allowfullscreen=\"true\" mozallowfullscreen=\"true\" webkitallowfullscreen=\"true\"></iframe>"
    end
  end
end
