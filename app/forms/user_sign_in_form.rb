class UserSignInForm < Reform::Form
  include EmailBounceValidatable

  property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
  property :referer
  property :shared_device

  validate :user_with_email_must_exist

  def user_with_email_must_exist
    return if user.present?
    errors[:email] << 'Could not find user with this email'
  end

  def save
    response = Users::AuthenticationService.mail_login_token(email, referer, shared_device?)
    raise "Unexpected error while emailing token to #{email}" unless response[:success]
  end

  private

  def user
    @user ||= begin
      User.with_email(email).first unless email.blank?
    end
  end

  def shared_device?
    shared_device == '1'
  end
end
