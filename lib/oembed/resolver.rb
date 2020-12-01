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
      uri = URI.parse(@url)

      klass = providers.find do |provider_klass|
        string_matches_any?(uri.host, provider_klass.domains) &&
          string_matches_any?(uri.path, provider_klass.paths)
      end

      return klass if klass.present?

      fallback_klass = fallback_providers.find do |fallback_provider_klass|
        string_matches_any?(uri.host, fallback_provider_klass.domains) &&
          string_matches_any?(uri.path, fallback_provider_klass.paths)
      end

      return fallback_klass if fallback_klass.present?

      raise ProviderNotSupported, "The hostname '#{uri.host}' could not be resolved to any known provider."
    end

    def string_matches_any?(string, regexes)
      regexes.any? { |regex| string.match?(regex) }
    end

    def providers
      [
        Oembed::YoutubeProvider,
        Oembed::VimeoProvider,
        Oembed::SlideshareProvider,
      ]
    end

    def fallback_providers
      [
        Oembed::GoogleDocumentsFallbackProvider,
        Oembed::GoogleSlidesFallbackProvider,
        Oembed::GoogleSpreadsheetsFallbackProvider,
        Oembed::GoogleFormsFallbackProvider
      ]
    end
  end
end
