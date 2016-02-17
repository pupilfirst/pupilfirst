# Mails sent out to startups, as a whole.
class StartupMailer < ApplicationMailer
  def startup_approved(startup)
    @startup = startup
    send_to = @startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'You are now part of Startup Village!')
  end

  def startup_dropped_out(startup)
    @startup = startup
    send_to = @startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Incubation Request update.')
  end

  def feedback_as_email(startup_feedback, founder: nil)
    @startup_feedback = startup_feedback

    send_to = if founder
      founder.email
    else
      startup_feedback.startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    end

    mail(to: send_to, subject: 'Feedback from Team SV.')
  end

  # Mail sent to startup founders once a connect request is confirmed.
  #
  # @param connect_request [ConnectRequest] Request that was just confirmed
  def connect_request_confirmed(connect_request)
    @connect_request = connect_request
    send_to = connect_request.startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Connect Request confirmed.')
  end
end
