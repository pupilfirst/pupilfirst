class TargetVersion < ApplicationRecord
  belongs_to :target
  has_many :content_blocks, dependent: :destroy
  validates_with RateLimitValidator,
                 limit: 25,
                 scope: :target_id,
                 time_frame: 1.day
end
