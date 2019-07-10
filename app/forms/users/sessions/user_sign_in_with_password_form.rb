class UserSignInWithPasswordForm < Reform::Form
  attr_accessor :current_school

  property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
  property :password, validates: { presence: true }
  property :shared_device

  validate :user_profile_must_exist
  validate :must_have_valid_password

  def user
    @user ||= begin
      User.with_email(email) if email.present?
    end
  end

  private

  def user_profile_must_exist
    return if user_profile.present?

    errors[:base] << "Invalid email or password"
  end

  def must_have_valid_password
    return if user_profile.blank?

    return unless valid_password_digest?

    return if user_profile.authenticate(password)

    errors[:base] << "Invalid email or password"
  end

  def valid_password_digest?
    return true if user_profile&.password_digest&.present?

    errors[:base] << "You haven't created a password yet, Please use forgot password to set a new password"
    false
  end

  def user_profile
    @user_profile ||= begin
      if user.present? && current_school.present?
        user.user_profiles.where(school: current_school).first
      end
    end
  end
end
