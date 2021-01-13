class AddCategoryToNews < ActiveRecord::Migration[4.2]
  def change
    add_column :news, :category_id, :integer
  end
end
