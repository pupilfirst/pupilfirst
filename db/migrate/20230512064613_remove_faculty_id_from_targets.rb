class RemoveFacultyIdFromTargets < ActiveRecord::Migration[6.1]
  def change
    remove_column :targets, :faculty_id, :integer, index: true
  end
end
