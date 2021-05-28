class UserSessionMailer < SchoolMailer
  layout 'mail/school_redesign'

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

  def set_first_password_token(user, school, first_password_url)
    @school = school
    @user = user

    @first_password_url = first_password_url

    simple_roadie_mail(@user.email, "You have been added as a student in #{@school.name}")
  end
end
