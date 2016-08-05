class AddFacultyIdToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :faculty_id, :integer
    add_index :admin_users, :faculty_id
  end
end
