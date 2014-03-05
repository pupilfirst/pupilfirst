class UserMailer < ActionMailer::Base
  default from: "SV App <no-reply@svlabs.in>"

  def password_changed(user)
    @user = user
    mail(to: user.email, subject: "Your password has been changed")
  end
end
