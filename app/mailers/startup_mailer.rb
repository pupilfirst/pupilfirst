class StartupMailer < ActionMailer::Base
  default from: "SV App <no-reply@svlabs.in>"

  def respond_to_new_employee(startup, new_employee)
    @new_employee = new_employee
    @startup = startup
    send_to = startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    substitute '-founder_full_name-', startup.founders.map(&:fullname)
    mail(to: send_to, subject: "Approve new employee at #{startup.name}")
  end
end
