class RemoveFeePaymentMethodFromFounder < ActiveRecord::Migration[5.1]
  def change
    remove_column :founders, :fee_payment_method, :string
  end
end
