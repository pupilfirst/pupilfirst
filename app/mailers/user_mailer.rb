# Mails sent out to startups, as a whole.
class UserMailer < ApplicationMailer
  def send_login_token(user, url)
    @user = user
    @referer = url || root_url
    mail(to: @user.email, subject: 'Log in to SV.CO')
  end
end
