class UpdateUserMutator < ApplicationQuery
  property :id, validates: { presence: true }
  property :name, validates: { presence: true }
  property :about, validates: { length: { maximum: 1000 } }
  property :current_password
  property :new_password
  property :confirm_new_password
  property :daily_digest

  validate :current_password_must_be_valid
  validate :new_passwords_should_match
  validate :passwords_should_be_secure

  def update_user
    User.transaction do
      current_user.update!(user_params)

      return if new_password.blank?

      user.password = new_password
      user.password_confirmation = confirm_new_password
      user.save!
    end
  end

  private

  def current_password_must_be_valid
    return if new_password.blank? || user.encrypted_password.blank? || user.valid_password?(current_password)

    errors[:base] << 'current password is incorrect'
  end

  def new_passwords_should_match
    return if new_password == confirm_new_password

    errors[:base] << 'new password does not match'
  end

  def passwords_should_be_secure
    return if new_password.blank? || new_password.length >= 8

    errors[:base] << 'new password should be at least 8 characters long'
  end

  def authorized?
    current_user == user
  end

  def user
    @user ||= User.find_by(id: id)
  end

  def user_params
    {
      name: name,
      about: about,
      preferences: {
        daily_digest: daily_digest
      }
    }
  end
end
