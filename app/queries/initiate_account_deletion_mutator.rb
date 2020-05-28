class InitiateAccountDeletionMutator < ApplicationQuery
  property :password, validates: { presence: true }

  def execute
    Users::MailAccountDeletionTokenService.new(current_user).execute
  end

  private

  def authorized?
    current_user.present? && current_user.valid_password?(password)
  end
end
