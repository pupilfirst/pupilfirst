class StartupFeedback < ActiveRecord::Base
  belongs_to :startup
  attr_accessor :send_email

  REGEX_TIMELINE_EVENT_URL = /startups\/.*event-(?<event_id>[\d]+)/

  def for_timeline_event?
    self.reference_url.present? && self.reference_url.match(REGEX_TIMELINE_EVENT_URL).present? ? true : false
  end

  def timeline_event
    self.reference_url.present? && self.reference_url.match(REGEX_TIMELINE_EVENT_URL).present? ? TimelineEvent.find(self.reference_url.match(REGEX_TIMELINE_EVENT_URL)[:event_id]) : nil
  end


end
