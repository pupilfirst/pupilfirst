class UserSessionMailer < SchoolMailer
  def send_login_token(user, url_options, input_token)
    @user = user
    @school = user.school
    @school_name = @school.name
    @url_options = url_options
    @input_token = input_token

    simple_mail(
      user.email,
      "#{I18n.t("mailers.user_session.send_login_token.subject", school_name: @school_name)}",
      enable_reply: false
    )
  end

  def send_reset_password_token(user, school, reset_password_url)
    @user = user
    @school = school
    @school_name = school.name
    @reset_password_url = reset_password_url

    simple_mail(
      user.email,
      "#{@school_name} #{I18n.t("mailers.user_session.send_reset_password_token.subject")}",
      enable_reply: false
    )
  end
end
