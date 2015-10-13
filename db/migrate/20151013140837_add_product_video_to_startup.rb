class AddProductVideoToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :product_video, :string
  end
end
