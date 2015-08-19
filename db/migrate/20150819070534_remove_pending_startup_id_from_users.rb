class RemovePendingStartupIdFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :pending_startup_id, :integer
  end
end
