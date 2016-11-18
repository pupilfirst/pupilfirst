class AddRefundedToPayment < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :refunded, :boolean
  end
end
