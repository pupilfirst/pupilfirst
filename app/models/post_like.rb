class PostLike < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true

  validates_with RateLimitValidator,
                 limit: 250,
                 scope: :user_id,
                 time_frame: 1.hour
end
