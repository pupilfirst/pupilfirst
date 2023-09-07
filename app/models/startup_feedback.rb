class StartupFeedback < ApplicationRecord
  belongs_to :faculty, optional: true
  belongs_to :timeline_event
  attr_accessor :send_email, :event_id, :event_status

  validates :feedback, presence: true

  normalize_attribute :activity_type

  validates_with RateLimitValidator,
                 limit: 25,
                 scope: :timeline_event_id,
                 time_frame: 1.hour

  # Returns all feedback for a given timeline event.
  def self.for_timeline_event(event)
    where(timeline_event: event).order("updated_at desc")
  end
end
