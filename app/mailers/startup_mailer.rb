class StartupMailer < ApplicationMailer
  # Mail sent to startup whose agreement with SV is expiring soon.
  #
  # @param startup [Startup] Startup whose agreement is expiring
  # @param expires_in [Fixnum] Days till expiry

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

  # def bank_approved(startup)
  #   @startup = startup
  #   send_to = startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
  #   substitute '-founder_full_name-', startup.founders.map(&:fullname)
  #   mail(to: send_to, subject: "Your startup's has been approved")
  # end

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

  def notify_svrep_about_startup_update(startup)
    @startup = startup
    mail(to: admin_contact, cc: "incoming@svlabs.in", subject: "Detailed form submitted")
  end

  def apply_now(startup)
    @startup = startup
    mail(to: admin_contact, cc: "incoming@svlabs.in", subject: "Incubation Application")
  end

  # def respond_to_new_employee(startup, new_employee)
  #   @new_employee = new_employee
  #   @startup = startup
  #   send_to = startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
  #   substitute '-founder_full_name-', startup.founders.map(&:fullname)
  #   mail(to: send_to, subject: "Approve #{@new_employee.fullname} at #{@startup.name}")
  # end

  private

  def secretary_contact
    I18n.t("startup_village.secretary_contact.#{Rails.env}") or 'info@svlabs.in'
  end

  def admin_contact
    I18n.t("startup_village.admin_contact.#{Rails.env}") or 'info@svlabs.in'
  end
end
