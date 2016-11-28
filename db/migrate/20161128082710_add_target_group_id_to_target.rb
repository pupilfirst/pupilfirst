class AddTargetGroupIdToTarget < ActiveRecord::Migration[5.0]
  def change
    add_column :targets, :target_group_id, :integer
  end
end
