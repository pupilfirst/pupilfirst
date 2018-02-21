# Mails sent out to startups, as a whole.
class StartupMailer < ApplicationMailer
  def startup_dropped_out(startup)
    @startup = startup
    send_to = @startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Your Team has Dropped Out')
  end

  def feedback_as_email(startup_feedback, founder: nil)
    @startup_feedback = startup_feedback
    send_to = founder&.email || startup_feedback.startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Feedback from Team SV')
  end

  # Mail sent to startup founders once a connect request is confirmed.
  #
  # @param connect_request [ConnectRequest] Request that was just confirmed
  def connect_request_confirmed(connect_request)
    @connect_request = connect_request
    send_to = connect_request.startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Connect Request confirmed.')
  end

  def payment_reminder(payment)
    @payment = payment
    send_to = payment.startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: "Your SV.CO subscription expires in #{payment.days_to_expiry} days.")
  end
end
