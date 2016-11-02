class AddFeePaymentMethodToBatchApplicant < ActiveRecord::Migration[5.0]
  def change
    add_column :batch_applicants, :fee_payment_method, :string
  end
end
