class UpdateUserMutator < ApplicationQuery
  property :name, validates: { presence: true }
  property :about, validates: { length: { maximum: 1000 } }
  property :current_password, validates: { presence: true, length: { minimum: 8, maximum: 128 }, allow_blank: true }
  property :new_password, validates: { presence: true, length: { minimum: 8, maximum: 128 }, allow_blank: true }
  property :confirm_new_password, validates: { presence: true, length: { minimum: 8, maximum: 128 }, allow_blank: true }
  property :daily_digest

  validate :current_password_must_be_valid
  validate :new_passwords_should_match

  def update_user
    User.transaction do
      current_user.update!(user_params)

      return if new_password.blank?

      current_user.password = new_password
      current_user.password_confirmation = confirm_new_password
      current_user.save!
    end
  end

  private

  def current_password_must_be_valid
    return if new_password.blank? || current_user.encrypted_password.blank? || current_user.valid_password?(current_password)

    errors[:base] << 'Current password is incorrect'
  end

  def new_passwords_should_match
    return if new_password == confirm_new_password

    errors[:base] << 'New password does not match'
  end

  def authorized?
    current_user.present?
  end

  def user_params
    preferences = current_user.preferences
    preferences[:daily_digest] = daily_digest
    {
      name: name,
      about: about,
      preferences: preferences
    }
  end
end
