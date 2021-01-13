class AddStartupIdToResources < ActiveRecord::Migration[4.2]
  def change
    add_column :resources, :startup_id, :integer
    add_index :resources, :startup_id
  end
end
