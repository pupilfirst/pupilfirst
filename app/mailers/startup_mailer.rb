class StartupMailer < ActionMailer::Base
  default from: "no-reply@svlabs.in"

  def respond_to_new_employee(startup, new_employee)
    @new_employee = new_employee
    @startup = startup
    send_to = startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    mail(to: send_to, subject: "Approve new employee at #{startup.name}")
  end
end
