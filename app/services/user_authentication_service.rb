# Service responsible for emailing user login_tokens and authenticating them.
class UserAuthenticationService
  attr_reader :email, :referer, :token, :user

  def initialize(email:, referer: nil, token: nil)
    @email = email
    @user = User.where(email: email).first
    @referer = referer
    @token = token
  end

  def self.mail_login_token(email, referer)
    new(email: email, referer: referer).mail_login_token
  end

  def self.authenticate_token(email, token)
    new(email: email, token: token).authenticate_token
  end

  def mail_login_token
    return user_not_found_error unless user.present?

    user.regenerate_login_token unless Rails.env.development?

    send_token
    mail_success_response
  end

  def authenticate_token
    token_valid? ? authentication_success_response : authentication_failure_response
  end

  private

  def user_not_found_error
    { success: false, message: 'Could not find user with given email.' }
  end

  def send_token
    UserSessionMailer.send_login_token(user, referer).deliver_now
  end

  def mail_success_response
    { success: true, message: 'Login token successfully emailed.' }
  end

  def token_valid?
    user && token == user.login_token
  end

  def authentication_success_response
    { success: true, message: 'User authenticated successfully.' }
  end

  def authentication_failure_response
    { success: false, message: 'User authentication failed.' }
  end
end
