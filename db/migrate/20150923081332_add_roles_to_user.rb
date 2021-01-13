class AddRolesToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :roles, :string
  end
end
