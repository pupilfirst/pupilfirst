# Mails sent out to startups, as a whole.
class StartupMailer < ApplicationMailer
  # Mail sent to startup whose agreement with SV.CO is expiring soon.
  #
  # @param startup [Startup] Startup whose agreement is expiring
  # @param expires_in [Fixnum] Days till expiry
  # @param renew_within [Fixnum] Days to renew
  def agreement_expiring_soon(startup, expires_in, renew_within)
    @startup = startup
    @expires_in = expires_in
    @renew_within = renew_within

    send_to = @startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Reminder to renew your incubation agreement with Startup Village')
  end

  def startup_approved(startup)
    @startup = startup
    send_to = @startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'You are now part of Startup Village!')
  end

  def startup_rejected(startup)
    @startup = startup
    send_to = @startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Incubation Request update.')
  end

  def startup_dropped_out(startup)
    @startup = startup
    send_to = @startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Incubation Request update.')
  end

  def reminder_to_complete_startup_profile(startup)
    @startup = startup
    send_to = @startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Reminder to complete your startup profile')
  end

  def reminder_to_complete_startup_info(startup)
    @startup = startup
    send_to = @startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: 'Reminder to complete incubation application to Startup Village.')
  end

  def feedback_as_email(startup_feedback)
    @startup_feedback = startup_feedback
    send_to = startup_feedback.startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
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
