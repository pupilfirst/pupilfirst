module Oembed
  class GenericProvider
    attr_reader :resource_url
    def initialize(resource_url)
      @resource_url = resource_url
    end
    def embed_code
      "<iframe src=\"#{resource_url}\" frameborder=\"0\" width=\"960\" height=\"569\" allowfullscreen=\"true\" mozallowfullscreen=\"true\" webkitallowfullscreen=\"true\"></iframe>"
    end
  end
end
