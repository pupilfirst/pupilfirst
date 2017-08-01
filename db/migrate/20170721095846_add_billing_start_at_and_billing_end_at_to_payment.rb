class AddBillingStartAtAndBillingEndAtToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :billing_start_at, :datetime
    add_column :payments, :billing_end_at, :datetime
  end
end
