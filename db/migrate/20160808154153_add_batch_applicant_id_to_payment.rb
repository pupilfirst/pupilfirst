class AddBatchApplicantIdToPayment < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :batch_applicant_id, :integer
    add_index :payments, :batch_applicant_id
  end
end
