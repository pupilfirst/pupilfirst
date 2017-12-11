class RenameTargetAssignerToFaculty < ActiveRecord::Migration[5.1]
  def change
    rename_column :targets, :assigner_id, :faculty_id
    add_index :targets, :faculty_id
  end
end
