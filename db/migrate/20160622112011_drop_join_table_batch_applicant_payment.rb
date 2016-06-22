class DropJoinTableBatchApplicantPayment < ActiveRecord::Migration
  def up
    drop_join_table :batch_applicants, :payments
  end

  def down
    create_join_table :batch_applicants, :payments do |t|
      t.index [:batch_applicant_id, :payment_id], name: 'idx_applicants_payments_on_applicant_id_and_payment_id'
      t.index [:payment_id, :batch_applicant_id], name: 'idx_applicants_payments_on_payment_id_and_applicant_id'
    end
  end
end
