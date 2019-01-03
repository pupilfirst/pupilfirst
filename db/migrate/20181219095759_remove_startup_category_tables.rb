class RemoveStartupCategoryTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :startup_categories_startups
    drop_table :startup_categories
  end
end
