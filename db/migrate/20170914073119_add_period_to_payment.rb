class AddPeriodToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :period, :integer, default: 1
  end
end
