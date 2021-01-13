class RenameCategoriesToStartupCategories < ActiveRecord::Migration[4.2]
  def change
    rename_table :categories, :startup_categories
  end
end
