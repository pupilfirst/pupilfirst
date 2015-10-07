class DropCategoriesUsersTable < ActiveRecord::Migration
  def change
    drop_table :categories_users
  end
end
