class AuditRecord < ApplicationRecord
  belongs_to :school

  TYPE_DELETE_ACCOUNT = 'delete_account'
  TYPE_ADD_SCHOOL_ADMIN = 'add_school_admin'
  TYPE_REMOVE_SCHOOL_ADMIN = 'remove_school_admin'
  TYPE_DROPOUT_STUDENT = 'dropout_student'

  def self.valid_audit_types
    [TYPE_DELETE_ACCOUNT, TYPE_ADD_SCHOOL_ADMIN, TYPE_REMOVE_SCHOOL_ADMIN, TYPE_DROPOUT_STUDENT].freeze
  end

  validates :audit_type, presence: true, inclusion: { in: valid_audit_types }
end
