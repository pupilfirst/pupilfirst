class RemovePeriodFromPayment < ActiveRecord::Migration[5.1]
  def change
    remove_column :payments, :period, :integer
  end
end
