class AddStartupAdminToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :startup_admin, :boolean
  end
end
