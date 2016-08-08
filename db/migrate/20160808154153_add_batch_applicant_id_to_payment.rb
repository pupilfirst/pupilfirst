class AddBatchApplicantIdToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :batch_applicant_id, :integer
    add_index :payments, :batch_applicant_id
  end
end
