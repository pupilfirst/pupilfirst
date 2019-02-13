class StartupFeedback < ApplicationRecord
  belongs_to :startup
  belongs_to :faculty
  belongs_to :timeline_event, optional: true
  attr_accessor :send_email, :event_id, :event_status

  validates :feedback, presence: true

  normalize_attribute :activity_type

  # Returns all feedback for a given timeline event.
  def self.for_timeline_event(event)
    where(timeline_event: event).order('updated_at desc')
  end

  def for_founder?
    timeline_event.present? ? timeline_event.founder_event? : false
  end
end
