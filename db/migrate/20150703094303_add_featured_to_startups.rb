class AddFeaturedToStartups < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :featured, :boolean
  end
end
