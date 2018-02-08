class RemoveRefundedFromPayment < ActiveRecord::Migration[5.1]
  def change
    remove_column :payments, :refunded
  end
end
