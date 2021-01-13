class AddProductNameAndDescriptionToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :product_name, :string
    add_column :startups, :product_description, :string
  end
end
