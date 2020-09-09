class DeleteAccountMutator < ApplicationQuery
  property :token, validates: { presence: true }

  def execute
    User.transaction do
      create_audit_record(user)
      Users::DeleteAccountJob.perform_later(current_user)
    end
  end

  private

  def authorized?
    user.present? && user.school == current_school
  end

  def user
    @user ||= User.find_by_hashed_delete_account_token(token) # rubocop:disable Rails/DynamicFindBy
  end

  def create_audit_record(user)
    AuditRecord.create!(audit_type: AuditRecord::TYPE_DELETE_ACCOUNT, school_id: current_school.id, metadata: { email: user.email })
  end
end
