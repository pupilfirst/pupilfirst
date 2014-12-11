class RenameStartupsCategoriesToCategoriesStartups < ActiveRecord::Migration
  def change
    rename_table :startups_categories, :categories_startups
  end
end
