class DropCategoriesUsersTable < ActiveRecord::Migration[4.2]
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
