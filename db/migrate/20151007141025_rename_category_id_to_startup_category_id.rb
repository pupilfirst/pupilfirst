class RenameCategoryIdToStartupCategoryId < ActiveRecord::Migration
  def change
    rename_column :categories_startups, :category_id, :startup_category_id
  end
end
