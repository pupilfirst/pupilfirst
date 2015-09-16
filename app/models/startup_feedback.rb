class StartupFeedback < ActiveRecord::Base
  belongs_to :startup
  attr_accessor :send_email

  REGEX_TIMELINE_EVENT_URL = %r{startups/.*event-(?<event_id>[\d]+)}

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
