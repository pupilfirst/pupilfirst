class RemoveTagsFromStartups < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :tags
  end
end
