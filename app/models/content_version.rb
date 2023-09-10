class ContentVersion < ApplicationRecord
  belongs_to :target
  belongs_to :content_block

  validates :sort_index, presence: true
  validates :version_on, presence: true
  validates_with RateLimitValidator, limit: 100, scope: :target_id
end
