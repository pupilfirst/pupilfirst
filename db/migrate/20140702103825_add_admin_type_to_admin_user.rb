class AddAdminTypeToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :admin_type, :string
  end
end
