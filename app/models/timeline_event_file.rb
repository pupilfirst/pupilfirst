class TimelineEventFile < ApplicationRecord
  belongs_to :timeline_event, optional: true
  has_one_attached :file

  validates :file, attached: true
  validates_with RateLimitValidator, limit: 5, scope: :timeline_event_id

  delegate :filename, to: :file
end
