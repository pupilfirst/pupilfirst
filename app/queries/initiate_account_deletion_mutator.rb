class InitiateAccountDeletionMutator < ApplicationQuery
  property :id, validates: { presence: true }
  property :password, validates: { presence: true }

  validate :password_must_be_valid
  validate :user_must_not_be_admin

  def execute
    Users::MailAccountDeletionTokenService.new(current_user).execute
  end

  private

  def authorized?
    current_user.present? && current_user == user
  end

  def password_must_be_valid
    return if current_user.valid_password?(password)

    errors[:base] << 'not a valid password'
  end

  def user_must_not_be_admin
    return if current_school_admin.blank?

    errors[:base] << 'admin rights in school not revoked'
  end

  def user
    User.find_by(id: id)
  end
end
