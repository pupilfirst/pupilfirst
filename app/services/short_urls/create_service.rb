module ShortUrls
  # Used to shorten URLs.
  class ShortenService
    def new(url)
      @url = url
    end

    # @return [ShortUrl] Retrieved or created ShortUrl entry.
    def find_or_create
      @short_url ||= begin
      end
    end

    # @return [String] Return a shortened URL of the form sv.co/s/xxxxxx
    # def short_url
    #   find_or_create.short_url
    # end
  end
end
