class StartupFeedback < ActiveRecord::Base
  belongs_to :startup
  belongs_to :faculty
  attr_accessor :send_email

  scope :for_batch, -> (batch_number) { joins(:startup).where(startups: { batch_number: batch_number }) }

  validates_presence_of :faculty, :feedback

  REGEX_TIMELINE_EVENT_URL = %r{startups/.*event-(?<event_id>[\d]+)}

  # Returns all feedback for a given timeline event.
  def self.for_timeline_event(event)
    where('reference_url LIKE ?', "%event-#{event.id}").order('updated_at desc')
  end

  def for_timeline_event?
    if reference_url.present? && reference_url.match(REGEX_TIMELINE_EVENT_URL).present?
      true
    else
      false
    end
  end

  def timeline_event
    return unless reference_url.present? && reference_url.match(REGEX_TIMELINE_EVENT_URL).present?
    TimelineEvent.find(reference_url.match(REGEX_TIMELINE_EVENT_URL)[:event_id])
  end
end
