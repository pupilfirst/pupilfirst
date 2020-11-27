module Oembed
  class GSlideFallbackProvider < GenericProvider
    def self.domains
      [/docs\.google\.com/]
    end

    def resource_url
      full_path, query = @resource_url.split('?')
      splited_full_path = full_path.split('/')
      splited_full_path.pop # remove 'pub' action
      splited_full_path.push('embed')
      splited_full_path.join('/') + "?#{query}"
    end
  end
end
