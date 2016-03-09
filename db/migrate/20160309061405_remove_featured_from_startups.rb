class RemoveFeaturedFromStartups < ActiveRecord::Migration
  def change
    remove_column :startups, :featured, :boolean
  end
end
