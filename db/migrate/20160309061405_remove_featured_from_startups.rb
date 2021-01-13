class RemoveFeaturedFromStartups < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :featured, :boolean
  end
end
