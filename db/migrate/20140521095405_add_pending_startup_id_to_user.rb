class AddPendingStartupIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :pending_startup_id, :integer
  end
end
