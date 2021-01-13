class AddPaidAtToPayment < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :paid_at, :datetime
  end
end
