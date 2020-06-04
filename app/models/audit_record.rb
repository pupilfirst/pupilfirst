class AuditRecord < ApplicationRecord
  TYPE_DELETE_ACCOUNT = 'delete_account'
  TYPE_ADD_SCHOOL_ADMIN = 'add_school_admin'
  TYPE_REMOVE_SCHOOL_ADMIN = 'remove_school_admin'
  TYPE_DROPOUT_STUDENT = 'dropout_student'

  def self.valid_audit_type
    [TYPE_DELETE_ACCOUNT, TYPE_ADD_SCHOOL_ADMIN, TYPE_REMOVE_SCHOOL_ADMIN, TYPE_DROPOUT_STUDENT].freeze
  end

  validate :audit_data_shape

  def audit_data_shape
    return if data['type'].in?(self.class.valid_audit_type) && data['log'].present?

    errors[:data] << 'not a valid audit record data'
  end
end
