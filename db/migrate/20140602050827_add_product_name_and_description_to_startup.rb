class AddProductNameAndDescriptionToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :product_name, :string
    add_column :startups, :product_description, :string
  end
end
