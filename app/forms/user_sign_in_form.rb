class UserSignInForm < Reform::Form
  property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
  property :referer

  validate :user_with_email_exist

  def user_with_email_exist
    return if User.find_by(email: email).present?
    errors[:email] << 'Could not find user with this email'
  end

  def save
    response = UserAuthenticationService.mail_login_token(email, referer)
    raise "Unexpected error while emailing token to #{email}" unless response[:success]
  end
end
