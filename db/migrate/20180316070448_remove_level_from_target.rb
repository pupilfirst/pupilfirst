class RemoveLevelFromTarget < ActiveRecord::Migration[5.1]
  def change
    remove_column :targets, :level_id, :integer
  end
end
