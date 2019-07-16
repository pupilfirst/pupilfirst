class UserSignInWithEmailForm < Reform::Form
  attr_accessor :current_school

  property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
  # Honeypot field. See validation `detect_honeypot` below.
  property :username

  validate :user_profile_must_exist

  def user_profile_must_exist
    return if user_profile.present? || email.blank?

    errors[:base] << 'Could not find user with this email. Please check the email that you entered.'
  end

  # validate :ensure_time_between_requests
  #
  # def ensure_time_between_requests
  #   return if user.blank?
  #   return if user.login_mail_sent_at.blank?
  #
  #   time_since_last_mail = Time.zone.now - user.login_mail_sent_at
  #   return if time_since_last_mail > 2.minutes
  #
  #   errors[:email] << 'An email was sent less than two minutes ago.'
  #   errors[:base] << "Please wait for a few minutes before trying again."
  # end

  validate :detect_honeypot

  def detect_honeypot
    return if username.blank?

    errors[:base] << 'Your request has been blocked because it is suspicious.'
  end

  def save(current_domain)
    Users::MailLoginTokenService.new(current_school, current_domain, user, referer, shared_device?).execute
  end

  private

  def user
    @user ||= begin
      User.with_email(email) if email.present?
    end
  end

  def user_profile
    @user_profile ||= begin
      if user.present? && current_school.present?
        user.user_profiles.where(school: current_school).first
      end
    end
  end
end
