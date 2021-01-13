class RemoveStartupIdFromTarget < ActiveRecord::Migration[4.2]
  def change
    remove_column :targets, :startup_id, :integer
  end
end
