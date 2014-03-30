class RemoveTagsFromStartups < ActiveRecord::Migration
  def change
    remove_column :startups, :tags
  end
end
