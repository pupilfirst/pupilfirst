class UserSignInForm < Reform::Form
  include EmailBounceValidatable

  property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
  property :referer
  property :shared_device

  validate :user_with_email_must_exist

  def user_with_email_must_exist
    return if user.present? || email.blank?

    errors[:email] << 'Could not find user with this email'
  end

  def save(current_school, current_domain)
    Users::MailLoginTokenService.new(current_school, current_domain, user, referer, shared_device?).execute
  end

  private

  def user
    @user ||= begin
      User.with_email(email) if email.present?
    end
  end

  def shared_device?
    shared_device == '1'
  end
end
