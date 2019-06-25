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
      # Resolve the provider and fetch embed code using the provider.
      provider.new(@url).embed_code
    end

    private

    def provider
      host_name = URI.parse(@url).hostname
      if host_name.include?('youtube')
        return Oembed::YoutubeProvider
      elsif host_name.include?('vimeo')
        return Oembed::VimeoProvider
      elsif host_name.include?('slideshare')
        return Oembed::SlideshareProvider
      else
        raise ProviderNotSupported
      end
    end
  end
end
