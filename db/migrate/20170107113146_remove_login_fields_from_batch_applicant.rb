class RemoveLoginFieldsFromBatchApplicant < ActiveRecord::Migration[5.0]
  def change
    remove_column :batch_applicants, :token, :string
    remove_column :batch_applicants, :sign_in_email_sent_at, :datetime
    remove_column :batch_applicants, :last_sign_in_at, :datetime
  end
end
