class RemoveFacultyIdFromAdminUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :admin_users, :faculty_id, :integer
  end
end
