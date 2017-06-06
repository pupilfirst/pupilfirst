class RenameTargetTypeToTargetActionType < ActiveRecord::Migration[5.0]
  def change
    rename_column :targets, :target_type, :target_action_type
  end
end
