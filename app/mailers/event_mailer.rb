class EventMailer < ApplicationMailer
  default from: 'notifications@svlabs.com'
 
  def event_registered_email(event)
    @event = event
    mail(to: @event.posters_email, subject: 'Event registered')
  end
end
