class RemoveLevelAndStartupFromResource < ActiveRecord::Migration[5.2]
  def change
    remove_column :resources, :startup_id
    remove_column :resources, :level_id
  end
end
