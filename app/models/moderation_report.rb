class ModerationReport < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true

  validates :user_id, uniqueness: { scope: %i[reportable_type reportable_id] }

  validates_with RateLimitValidator,
                 limit: 100,
                 scope: :user_id,
                 time_frame: 1.hour
end
