class UserMailer < ApplicationMailer
  def reminder_to_complete_founder_profile(user)
    @user = user
    mail to: @user.email, subject: 'Reminder to fill up founder profile'
  end

  def confirm_partnership_formation(partnership, requesting_user)
    @partnership = partnership
    @requesting_user = requesting_user

    mail to: @partnership.user.email, subject: 'Request to form partnership'
  end

  def cofounder_request(cofounder_mail, current_user)
    @current_user = current_user
    mail(to: cofounder_mail, subject: 'SVApp: You have been invited to join a Startup!')
  end

  def incubation_request_submitted(current_user)
    @current_user = current_user
    mail(to: current_user.email, subject: 'You have successfully submitted your request for incubation at Startup Village.')
  end

  def request_to_be_a_founder(user, startup, current_user)
    @startup = startup
    @user = user
    @current_user = current_user
    mail(to: user.email, subject: "Founder at #{@startup.name}? Please approve")
  end

  def password_changed(user)
    @user = user
    mail(to: user.email, subject: "Your password has been changed")
  end
end
