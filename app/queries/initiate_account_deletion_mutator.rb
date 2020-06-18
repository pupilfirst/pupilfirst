class InitiateAccountDeletionMutator < ApplicationQuery
  property :email, validates: { presence: true }

  validate :user_must_not_be_admin

  def execute
    Users::MailAccountDeletionTokenService.new(current_user).execute
  end

  private

  def authorized?
    current_user.present? && current_user.email == email
  end

  def password_must_be_valid
    return if current_user.valid_password?(password)

    errors[:base] << 'The password you supplied is not valid'
  end

  def user_must_not_be_admin
    return if current_school_admin.blank?

    errors[:base] << 'You are an admin; please delete your admin access before retrying'
  end

  def user
    User.find_by(id: id)
  end
end
