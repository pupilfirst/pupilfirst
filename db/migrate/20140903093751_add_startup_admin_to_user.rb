class AddStartupAdminToUser < ActiveRecord::Migration
  def change
    add_column :users, :startup_admin, :boolean
  end
end
