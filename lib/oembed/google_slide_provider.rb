module Oembed
  class GoogleSlideProvider < BaseProvider
    def initialize(resource_url)
      super(resource_url)

      full_path, query = resource_url.split('?')
      splited_full_path = full_path.split('/')
      splited_full_path.pop # remove 'pub' action
      splited_full_path.push('embed')
      embed_resource_url = splited_full_path.join('/') + "?#{query}"
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
