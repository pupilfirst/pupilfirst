class UpdateUserMutator < ApplicationQuery
  property :name, validates: { presence: true }
  property :preferred_name, validates: { length: { maximum: 128 } }
  property :about, validates: { length: { maximum: 1000 } }

  property :locale,
           validates: {
             presence: true,
             inclusion: {
               in: Settings.locale.available
             }
           }

  property :current_password,
           validates: {
             presence: true,
             length: {
               minimum: 8,
               maximum: 128
             },
             allow_blank: true
           }

  property :new_password,
           validates: {
             presence: true,
             length: {
               minimum: 8,
               maximum: 128
             },
             allow_blank: true
           }

  property :confirm_new_password,
           validates: {
             presence: true,
             length: {
               minimum: 8,
               maximum: 128
             },
             allow_blank: true
           }

  property :daily_digest

  validate :current_password_must_be_valid
  validate :new_passwords_should_match

  def update_user
    user_name = current_user.name

    if current_user.name != name.strip
      Users::LogUsernameUpdateService.new(current_user, name).execute
    end

    if new_password.blank?
      current_user.update!(user_params)
    else
      current_user.update!(
        user_params.merge(
          password: new_password,
          password_confirmation: confirm_new_password
        )
      )
    end

    if user_name != current_user.name
      Discord::SyncNameJob.perform_later(current_user)
    end
  end

  private

  def current_password_must_be_valid
    if new_password.blank? || current_user.encrypted_password.blank? ||
         current_user.valid_password?(current_password)
      return
    end

    errors.add(:base, "Current password is incorrect")
  end

  def new_passwords_should_match
    return if new_password == confirm_new_password

    errors.add(:base, "New password does not match")
  end

  def authorized?
    current_user.present?
  end

  def user_params
    preferences = current_user.preferences
    preferences[:daily_digest] = daily_digest
    {
      name: name,
      preferred_name: preferred_name,
      about: about,
      locale: locale,
      preferences: preferences
    }
  end
end
