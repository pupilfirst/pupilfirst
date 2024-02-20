class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :reactionable, polymorphic: true

  validates_with RateLimitValidator,
                 limit: 1000,
                 scope: :user_id,
                 time_frame: 1.hour
end
