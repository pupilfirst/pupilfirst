class RemoveAdminTypeFromAdminUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :admin_users, :admin_type, :string
  end
end
