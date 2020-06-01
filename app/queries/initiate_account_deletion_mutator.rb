class InitiateAccountDeletionMutator < ApplicationQuery
  property :id, validates: { presence: true }
  property :password, validates: { presence: true }

  validate :password_must_be_valid

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

  def user
    User.find_by(id: id)
  end
end
