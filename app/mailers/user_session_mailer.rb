class UserSessionMailer < SchoolMailer
  def send_login_token(user, url_options)
    @user = user
    @school = user.school
    @school_name = @school.name
    @url_options = url_options

    simple_roadie_mail(user.email, "Log in to #{@school_name}", enable_reply: false)
  end

  def send_reset_password_token(email, school, reset_password_url)
    @school = school
    @school_name = school.name
    @reset_password_url = reset_password_url

    simple_roadie_mail(email, "#{@school_name} account recovery", enable_reply: false)
  end
end
