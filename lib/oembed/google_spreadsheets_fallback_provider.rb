module Oembed
  class GoogleSpreadsheetsFallbackProvider < BaseFallbackProvider
    def self.domains
      [/docs\.google\.com/]
    end

    def self.paths
      [
        /^\/spreadsheets\/.*\/pubhtml$/,
      ]
    end

    def resource_url
      if @resource_url.include?('widget=true')
        @resource_url
      else
        @resource_url + '?widget=true&headers=false'
      end
    end
  end
end
