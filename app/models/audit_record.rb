class AuditRecord < ApplicationRecord
  belongs_to :school

  enum audit_type: {
         delete_account: "delete_account",
         add_school_admin: "add_school_admin",
         remove_school_admin: "remove_school_admin",
         dropout_student: "dropout_student",
         merge_user_accounts: "merge_user_accounts",
         update_email: "update_email",
         update_name: "update_name"
       }

  validates :audit_type, presence: true
end
