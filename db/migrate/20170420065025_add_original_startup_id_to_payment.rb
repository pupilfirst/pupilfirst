class AddOriginalStartupIdToPayment < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :original_startup_id, :integer
    add_index :payments, :original_startup_id
    add_foreign_key :payments, :startups, column: :original_startup_id
  end
end
