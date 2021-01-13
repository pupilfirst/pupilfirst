class AddPendingStartupIdToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :pending_startup_id, :integer
  end
end
