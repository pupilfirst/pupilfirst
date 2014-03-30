class RemoveCategoryFromStartups < ActiveRecord::Migration
  def change
    remove_column :startups, :category_id
  end
end
