class DeleteAccountMutator < ApplicationQuery
  property :token, validates: { presence: true }

  def execute
    User.transaction { Users::DeleteAccountJob.perform_later(current_user) }
  end

  private

  def authorized?
    user.present? && user.school == current_school
  end

  def user
    @user ||= User.find_by_hashed_delete_account_token(token) # rubocop:disable Rails/DynamicFindBy
  end
end
