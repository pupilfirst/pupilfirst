class RenameCategoriesToStartupCategories < ActiveRecord::Migration
  def change
    rename_table :categories, :startup_categories
  end
end
