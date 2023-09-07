class TimelineEventFile < ApplicationRecord
  belongs_to :timeline_event, optional: true
  belongs_to :user

  has_one_attached :file

  validates :file, attached: true
  validates_with RateLimitValidator,
                 limit: 50,
                 scope: :user_id,
                 time_frame: 1.hour

  delegate :filename, to: :file
end
