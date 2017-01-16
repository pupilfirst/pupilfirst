class UserSignInForm < Reform::Form
  property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
  property :referer
  property :shared_device

  validate :user_with_email_must_exist
  validate :email_should_not_have_bounced

  def user_with_email_must_exist
    return if user.present?
    errors[:email] << 'Could not find user with this email'
  end

  def email_should_not_have_bounced
    return unless user&.email_bounced?
    errors[:base] << 'We cannot send a sign-in email to this address because a previous attempt failed. Please contact help@sv.co for more information.'
    errors[:email] << 'is an address which bounced'
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
