class AddPaymentTypeToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :payment_type, :string
  end
end
