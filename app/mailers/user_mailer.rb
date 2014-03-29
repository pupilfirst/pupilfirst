class UserMailer < ActionMailer::Base
  default from: "SV App <no-reply@svlabs.in>"

  def request_to_be_a_founder(user, startup, current_user)
    @startup = startup
    @user = user
    @current_user = current_user
    mail(to: user.email, subject: "Founder at #{@startup.name}? Please approve")
  end

  def inform_student_contact

  end

  def inform_student

  end

  def accepted_as_employee(user, startup)
    @startup = startup
    @user = user
    mail(to: user.email, subject: "You're approved at #{@startup.name}")
  end

  def password_changed(user)
    @user = user
    mail(to: user.email, subject: "Your password has been changed")
  end

private
  def student_contact
    I18n.t("startup_village.student_contact.#{Rails.env}") or 'info@svlabs.in'
  end

end
