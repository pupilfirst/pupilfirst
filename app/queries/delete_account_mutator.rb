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
    current_user.present? && current_user == user
  end

  def user
    @user ||= User.find_by(delete_account_token: token)
  end

  def create_audit_record(user)
    AuditRecord.create!(data: { 'type' => AuditRecord::TYPE_DELETE_ACCOUNT, 'log' => "Account email: #{user.email}; School ID: #{current_school.id}" })
  end
end
