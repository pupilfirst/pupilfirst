class AddIndexToTargetIdInResources < ActiveRecord::Migration[5.1]
  def change
    add_index :resources, :target_id
  end
end
