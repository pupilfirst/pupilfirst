module Oembed
  class Resolver
    class ResourceNotFound < StandardError
    end
    class ProviderNotSupported < StandardError
    end
    class FailedToResolve < StandardError
    end

    def initialize(url)
      @url = url
    end

    def embed_code
      # Resolve the provider for the supplied URL. Fail with ProviderNotSupported if one cannot be found.
      resolver = provider

      # Fetch embed code using the provider.
      resolver.new(url).embed_code
    end

    private

    def provider
      host_name = URI.parse(@url).hostname
      if host_name.include?('youtube')
        return YoutubeProvider
      elsif host_name.include?('vimeo')
        return VimeoProvider
      elsif host_name.include?['slideshare']
        return SlideshareProvider
      else
        raise ProviderNotSupported
      end
    end
  end
end
