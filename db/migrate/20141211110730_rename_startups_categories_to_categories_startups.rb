class RenameStartupsCategoriesToCategoriesStartups < ActiveRecord::Migration[4.2]
  def change
    rename_table :startups_categories, :categories_startups
  end
end
