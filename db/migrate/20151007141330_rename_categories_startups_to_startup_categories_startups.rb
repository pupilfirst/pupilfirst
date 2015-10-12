class RenameCategoriesStartupsToStartupCategoriesStartups < ActiveRecord::Migration
  def change
    rename_table :categories_startups, :startup_categories_startups
  end
end
