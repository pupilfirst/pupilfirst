class RenameCategoriesStartupsToStartupCategoriesStartups < ActiveRecord::Migration[4.2]
  def change
    rename_table :categories_startups, :startup_categories_startups
  end
end
