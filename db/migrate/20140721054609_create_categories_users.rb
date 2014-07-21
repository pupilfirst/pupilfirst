class CreateCategoriesUsers < ActiveRecord::Migration
  def change
    create_table :categories_users, id: false do |t|
      t.references :category
      t.references :user
    end
  end
end
