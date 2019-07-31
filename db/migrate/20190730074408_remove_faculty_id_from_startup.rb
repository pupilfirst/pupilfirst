class RemoveFacultyIdFromStartup < ActiveRecord::Migration[5.2]
  def up
    remove_column :startups, :faculty_id, :bigint
  end

  def down
    add_column :startups, :faculty_id, :bigint
    add_index :startups, :faculty_id
  end
end
