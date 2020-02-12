module Oembed
  class Resolver
    class ProviderNotSupported < StandardError
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

      klass = providers.find do |provider_klass|
        provider_klass.domains.any? do |domain_regex|
          host_name.match?(domain_regex)
        end
      end

      return klass if klass.present?

      raise ProviderNotSupported, "The hostname '#{host_name}' could not be resolved to any known provider."
    end

    def providers
      [
        Oembed::YoutubeProvider,
        Oembed::VimeoProvider,
        Oembed::SlideshareProvider
      ]
    end
  end
end
