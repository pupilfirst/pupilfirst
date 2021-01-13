class AddAdminTypeToAdminUser < ActiveRecord::Migration[4.2]
  def change
    add_column :admin_users, :admin_type, :string
  end
end
