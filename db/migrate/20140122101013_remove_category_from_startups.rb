class RemoveCategoryFromStartups < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :category_id
  end
end
