class AddTargetToResource < ActiveRecord::Migration[5.1]
  def change
    add_column :resources, :target_id, :integer
  end
end
