module ShortenedUrls
  # Used to shorten URLs.
  class ShortenService
    UniqueKeyUnavailable = Class.new(StandardError)

    include RoutesResolvable

    def initialize(url, expires_at: nil, unique_key: nil, host: 'sv.co')
      @url = url
      @expires_at = expires_at
      @unique_key = unique_key
      @host = host
    end

    # @return [String] Return a shortened URL of the form sv.co/r/xxxxxx
    def short_url
      url_helpers.short_redirect_url(unique_key: shortened_url.unique_key, host: @host)
    end

    # @return [ShortenedUrl] Return an instance of Shortened URL corresponding to supplied URL.
    def shortened_url
      @shortened_url ||= begin
        shortened_url = ShortenedUrl.find_by(url: @url)
        shortened_url.present? ? update_shortened_url(shortened_url) : create_shortened_url
      end
    end

    private

    def update_shortened_url(shortened_url)
      shortened_url.update!(expires_at: @expires_at) if @expires_at.present?
      return shortened_url if @unique_key.nil? || shortened_url.unique_key == @unique_key

      ensure_uniqueness_of_key
      shortened_url.update!(unique_key: @unique_key)
      shortened_url
    end

    def create_shortened_url
      ensure_uniqueness_of_key

      retries = 0

      begin
        ShortenedUrl.create!(url: @url, expires_at: @expires_at, unique_key: unique_key)
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
        raise 'Too many retries to generate unique_key for short URL.' if retries == 5

        retries += 1
        retry
      end
    end

    def ensure_uniqueness_of_key
      if ShortenedUrl.find_by(unique_key: @unique_key).present?
        raise UniqueKeyUnavailable, "The unique key '#{@unique_key}', that was supplied is already in use for another URL."
      end
    end

    # Return a random number (as string), of base 36, that's maximum 6 characters long.
    def unique_key
      @unique_key || rand(36**6).to_s(36).rjust(6, '0')
    end
  end
end
