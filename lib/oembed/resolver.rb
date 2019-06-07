module Oembed
  class Resolver
    class ResourceNotFound < StandardError; end
    class ProviderNotSupported < StandardError; end
    class FailedToResolve < StandardError; end

    def initialize(url)
      @url = url
    end

    def embed_code
      # Resolve the provider for the supplied URL. Fail with ProviderNotSupported if one cannot be found.
      resolver = SlideshareProvider

      # Fetch embed code using the provider.
      resolver.new(url).embed_code
    end
  end
end
