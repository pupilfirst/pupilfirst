class RemoveCategoryTypeFromCategory < ActiveRecord::Migration[4.2]
  def change
    remove_column :categories, :category_type, :string
  end
end
