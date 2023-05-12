class RemoveFacultyIdFromTargets < ActiveRecord::Migration[6.1]
  def up
    remove_index :targets, :faculty_id, if_exists: true
    remove_column :targets, :faculty_id, :integer
  end

  def down
    add_column :targets, :faculty_id, :integer
    add_index :targets, :faculty_id
  end
end
