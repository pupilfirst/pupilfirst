class StartupMailer < ActionMailer::Base
  default from: "SV App <no-reply@svlabs.in>", cc: "outgoing@svlabs.in"

  def partnership_application(startup, current_user)
    @startup = startup
    @current_user = current_user
    send_to = startup.founders.map { |e| "#{e.fullname} <#{e.email}>" } + ["incoming <incoming@svlabs.in>"]
    mail(to: [secretary_contact] + send_to, subject: "Request for registering a Partnership")
  end

  def startup_approved(startup)
    @startup = startup
    send_to = startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    substitute '-founder_full_name-', startup.founders.map(&:fullname)
    mail(to: send_to, subject: 'Welcome to Startup Village!')
  end

  def incorporation_approved(startup)
    @startup = startup
    send_to = startup.directors.map { |e| "#{e.fullname} <#{e.email}>" }
    substitute '-founder_full_name-', startup.directors.map(&:fullname)
    mail(to: send_to, subject: "Your startup's has been approved")
  end

  def bank_approved(startup)
    @startup = startup
    send_to = startup.directors.map { |e| "#{e.fullname} <#{e.email}>" }
    substitute '-founder_full_name-', startup.directors.map(&:fullname)
    mail(to: send_to, subject: "Your startup's has been approved")
  end

  def sep_approved(startup)
  end

  def fill_personal_info_for_director(startup)
  end

  def reminder_to_complete_personal_info(startup, current_user)
    @startup = startup
    @current_user = current_user
    directors = startup.directors.reject { |e| e.id == current_user.id}.reject { |d| d.personal_info_submitted? }
    send_to = directors.map { |e| "#{e.fullname} <#{e.email}>" }
    substitute '-founder_full_name-', directors.map(&:fullname)
    mail(to: send_to, subject: "#{current_user.fullname} has listed you as a Director at #{startup.name}")
  end

  def reminder_to_complete_startup_info(startup)
    @startup = startup
    send_to = startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    substitute '-founder_full_name-', startup.founders.map(&:fullname)
    mail(to: send_to, subject: 'Guide to complete the incubation process at SV.')
  end

  def notify_svrep_about_startup_update(startup)
    @startup = startup
    mail(to: admin_contact, cc: "incoming@svlabs.in", subject: "Detailed form submitted")
  end

  def apply_now(startup)
    @startup = startup
    mail(to: admin_contact, cc: "incoming@svlabs.in", subject: "Incubation Application")
  end

  def respond_to_new_employee(startup, new_employee)
    @new_employee = new_employee
    @startup = startup
    send_to = startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    substitute '-founder_full_name-', startup.founders.map(&:fullname)
    mail(to: send_to, subject: "Approve #{@new_employee.fullname} at #{@startup.name}")
  end

  private

  def secretary_contact
    I18n.t("startup_village.secretary_contact.#{Rails.env}") or 'info@svlabs.in'
  end

  def admin_contact
    I18n.t("startup_village.admin_contact.#{Rails.env}") or 'info@svlabs.in'
  end
end
