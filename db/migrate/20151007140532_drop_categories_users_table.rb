class DropCategoriesUsersTable < ActiveRecord::Migration
  def up
    drop_table :categories_users
  end

  def down
    create_table :categories_users, id: false do |t|
      t.references :category
      t.references :user
    end
  end
end
