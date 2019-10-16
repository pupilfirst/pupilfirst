# Mails sent out to teams, as a whole.
class StartupMailer < SchoolMailer
  def feedback_as_email(startup_feedback)
    @startup_feedback = startup_feedback
    send_to = startup_feedback.timeline_event.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    @school = startup_feedback.startup.school

    subject = "New feedback from #{startup_feedback.faculty.name} on your submission"
    simple_roadie_mail(send_to, subject)
  end

  # Mail sent to startup founders once a connect request is confirmed.
  #
  # @param connect_request [ConnectRequest] Request that was just confirmed
  def connect_request_confirmed(connect_request)
    @connect_request = connect_request
    send_to = connect_request.startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    @school = connect_request.startup.school

    simple_roadie_mail(send_to, 'Office hour confirmed.')
  end
end
