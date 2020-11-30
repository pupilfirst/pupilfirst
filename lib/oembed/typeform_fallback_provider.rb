module Oembed
  class TypeformFallbackProvider < GenericProvider
    def self.domains
      [/forms\.typeform\.com/]
    end

    def resource_url
      form_id = @resource_url.split(/\/to\/(?=[\w])/).last
      "https://form.typeform.com/to/#{form_id}"
    end
    def embed_code
      "<iframe id=\"typeform-full\" width=\"100%\" height=\"100%\" frameborder=\"0\" allow=\"camera; microphone; autoplay; encrypted-media;\" src=\"#{resource_url}\"></iframe>"
    end
  end
end
