class UserSignInForm < Reform::Form
  include EmailBounceValidatable

  property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
  property :referer
  property :shared_device

  # Honeypot field. See validation `detect_honeypot` below.
  property :username

  validate :user_with_email_must_exist

  def user_with_email_must_exist
    return if user.present? || email.blank?

    errors[:email] << 'Could not find user with this email.'
    errors[:base] << 'Please check the email that you entered.'
  end

  validate :ensure_time_between_requests

  def ensure_time_between_requests
    return if user.blank?
    return if user.login_mail_sent_at.blank?

    time_since_last_mail = Time.zone.now - user.login_mail_sent_at
    return if time_since_last_mail > 2.minutes

    errors[:email] << 'An email was sent less than two minutes ago.'
    errors[:base] << "Please wait for a few minutes before trying again."
  end

  validate :detect_honeypot

  def detect_honeypot
    return if username.blank?

    errors[:base] << 'Your request has been blocked because it is suspicious.'
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
