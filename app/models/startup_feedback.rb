class StartupFeedback < ActiveRecord::Base
  belongs_to :startup
  belongs_to :faculty
  attr_accessor :send_email

  scope :for_batch, -> (batch) { joins(:startup).where(startups: { batch_id: batch }) }

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

  def as_slack_message
    salutation = "Hey! You have some feedback from #{CGI.escape faculty.name} on your <#{CGI.escape reference_url}|recent update.>%0A"\
    "Here is what he had to say:%0A"
    # make transforms required by slack
    feedback_text = "\"" + CGI.escape(feedback) + "\"%0A"
    footer = "A copy of this feedback has been emailed to you."
    salutation + feedback_text + footer
  end
end
