class EventMailer < ApplicationMailer
  default from: 'notifications@svlabs.com'
 
  def event_registered_email(event)
    @event = event
    binding.pry
    mail(to: @event.posters_email, subject: 'Event Registered')
  end

  def event_approved_email(event)
    @event = event
    binding.pry
    mail(to: @event.posters_email, subject: 'Event Approved')
  end
end
