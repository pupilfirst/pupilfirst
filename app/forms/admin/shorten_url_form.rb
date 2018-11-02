# Accepts a long URL and transforms that to a short URL
module Admin
  class ShortenUrlForm < Reform::Form
    property :url, validates: { presence: true, url: true }
    property :unique_key, validates: { length: { maximum: 100 }, format: { with: /\A[a-zA-Z0-9\-_]+\z/, message: 'contains invalid characters' }, allow_blank: true }
    property :expires_at

    validate :no_other_url_for_key

    def no_other_url_for_key
      return if unique_key.blank?

      shortened_url = ShortenedUrl.find_by(unique_key: unique_key)
      return if shortened_url.blank? || shortened_url.url == url

      errors[:unique_key] << 'is already in use for another URL'
    end
  end
end
