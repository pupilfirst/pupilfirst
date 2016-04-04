class RemoveStartupIdFromTarget < ActiveRecord::Migration
  def change
    remove_column :targets, :startup_id, :integer
  end
end
