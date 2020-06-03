class DeleteAccountMutator < ApplicationQuery
  property :token, validates: { presence: true }

  def execute
    User.transaction do
      Users::DeleteAccountJob.perform_later(current_user)
    end
  end

  private

  def authorized?
    current_user.present? && current_user == user
  end

  def user
    @user ||= User.find_by(delete_account_token: token)
  end
end
