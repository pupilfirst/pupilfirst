class RemovePendingStartupIdFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :pending_startup_id, :integer
  end
end
