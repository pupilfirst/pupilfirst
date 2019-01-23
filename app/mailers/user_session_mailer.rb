# Mails sent out to startups, as a whole.
class UserSessionMailer < ApplicationMailer
  def send_login_token(email, school_name, login_url)
    @school_name = school_name
    @login_url = login_url

    mail(to: email, subject: "Log in to #{school_name}")
  end
end
