class AddFeaturedToStartups < ActiveRecord::Migration
  def change
    add_column :startups, :featured, :boolean
  end
end
