class UserSessionMailerPreview < ActionMailer::Preview
  def send_login_token
    login_url = Rails.application.routes.url_helpers.user_token_url(token: 'LOGIN_TOKEN', host: 'www.pupilfirst.localhost')
    UserSessionMailer.send_login_token('johndoe@example.com', nil, login_url)
  end
end
