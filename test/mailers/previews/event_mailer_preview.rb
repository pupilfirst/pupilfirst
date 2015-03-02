class EventMailerPreview < ActionMailer::Preview
  def event_registered_email
    EventMailer.event_registered_email(Event.first)
  end
end
