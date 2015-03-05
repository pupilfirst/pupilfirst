class EventMailerPreview < ActionMailer::Preview
	
  def event_registered_email
    EventMailer.event_registered_email(Event.first)
  end

  def event_approved_email
  	EventMailer.event_approved_email(Event.first)
  end

end
