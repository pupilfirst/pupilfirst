class ChangeProductDescriptionToText < ActiveRecord::Migration[4.2]
  def change
    change_column :startups, :product_description, :text
  end
end
