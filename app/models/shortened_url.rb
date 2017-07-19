class ShortenedUrl < ApplicationRecord
  validates :url, presence: true
  validates :unique_key, uniqueness: true, presence: true

  # Exclude records in which expiration time is set and expiration time is greater than current time.
  scope :unexpired, -> { where(expires_at: nil).or(where('expires_at > ?', Time.zone.now)) }

  # Mark another 'use' of this short URL.
  def use
    increment(:use_count)
    save!
  end
end
