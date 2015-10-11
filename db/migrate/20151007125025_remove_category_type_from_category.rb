class RemoveCategoryTypeFromCategory < ActiveRecord::Migration
  def change
    remove_column :categories, :category_type, :string
  end
end
