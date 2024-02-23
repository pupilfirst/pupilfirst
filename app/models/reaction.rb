class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :reactionable, polymorphic: true

  validates :user_id,
            uniqueness: {
              scope: %i[reactionable_type reactionable_id reaction_value]
            }

  validates_with RateLimitValidator,
                 limit: 1000,
                 scope: :user_id,
                 time_frame: 1.hour
end
