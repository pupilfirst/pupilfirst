class UserSessionMailerPreview < ActionMailer::Preview
  def send_login_token
    school_name = 'PupilFirst'
    login_url = Rails.application.routes.url_helpers.user_token_url(token: 'LOGIN_TOKEN', host: 'www.pupilfirst.localhost')

    UserSessionMailer.send_login_token('johndoe@example.com', school_name, login_url)
  end
end
