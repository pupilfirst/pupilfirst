class UserSessionMailerPreview < ActionMailer::Preview
  def send_login_token
    user = User.new(login_token: 'LOGIN_TOKEN')
    referer = Rails.application.routes.url_helpers.fee_founder_url
    shared_device = true

    UserSessionMailer.send_login_token(user, referer, shared_device)
  end
end
