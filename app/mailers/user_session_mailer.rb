class UserSessionMailer < SchoolMailer
  def send_login_token(email, school, login_url)
    @school = school
    @school_name = school.name
    @login_url = login_url

    simple_roadie_mail(email, "Log in to #{@school_name}", enable_reply: false)
  end

  def send_reset_password_token(email, school, reset_password_url)
    @school = school
    @school_name = school.name
    @reset_password_url = reset_password_url

    simple_roadie_mail(email, "#{@school_name} account recovery", enable_reply: false)
  end
end
