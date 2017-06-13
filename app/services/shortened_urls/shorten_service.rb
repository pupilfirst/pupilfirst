module ShortenedUrls
  # Used to shorten URLs.
  class ShortenService
    include RoutesResolvable

    def initialize(url, expires_at: nil)
      @url = url
      @expires_at = expires_at
    end

    # @return [String] Return a shortened URL of the form sv.co/r/xxxxxx
    def short_url
      url_helpers.short_redirect_url(unique_key: shortened_url.unique_key)
    end

    # @return [ShortenedUrl] Return an instance of Shortened URL corresponding to supplied URL.
    def shortened_url
      @shortened_url ||= begin
        shortened_url = ShortenedUrl.find_by(url: @url)
        shortened_url.present? ? shortened_url : create_shortened_url
      end
    end

    private

    def create_shortened_url
      retries = 0

      begin
        ShortenedUrl.create!(url: @url, expires_at: @expires_at, unique_key: unique_key)
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
        raise 'Too many retries to generate unique_key for short URL.' if retries == 5
        retries += 1
        retry
      end
    end

    # Return a random number (as string), of base 36, that's maximum 6 characters long.
    def unique_key
      rand(36**6).to_s(36).rjust(6, '0')
    end
  end
end
