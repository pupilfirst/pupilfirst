class AddProductVideoToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :product_video, :string
  end
end
