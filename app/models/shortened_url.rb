class ShortenedUrl < ApplicationRecord
  validates :url, presence: true
  validates :key, uniqueness: true, presence: true
end
