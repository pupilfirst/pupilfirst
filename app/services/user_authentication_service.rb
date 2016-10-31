# Service responsible for emailing user login_tokens and authenticating them.
class UserAuthenticationService
  def initialize(email: nil, referer: nil, token: nil)
    @email = email
    @user = User.where(email: email).first
    @referer = referer
    @token = token
  end

  def self.mail_login_token(email, referer)
    new(email: email, referer: referer).mail_login_token
  end

  def self.authenticate_token(token)
    new(token: token).authenticate_token
  end

  def mail_login_token
    return user_not_found_error unless @user.present?

    @user.regenerate_login_token

    send_token
    mail_success_response
  end

  def authenticate_token
    if token_valid?
      clear_token
      authentication_success_response
    else
      authentication_failure_response
    end
  end

  private

  def user_not_found_error
    { success: false, message: 'Could not find user with given email.' }
  end

  def send_token
    UserSessionMailer.send_login_token(@user, @referer).deliver_now
  end

  def mail_success_response
    { success: true, message: 'Login token successfully emailed.' }
  end

  def token_valid?
    return false if @token.blank?
    @user = User.find_by(login_token: @token)
  end

  def clear_token
    @user.update!(login_token: nil)
  end

  def authentication_success_response
    { success: true, message: 'User authenticated successfully.', user_id: @user.id }
  end

  def authentication_failure_response
    { success: false, message: 'User authentication failed.' }
  end
end
