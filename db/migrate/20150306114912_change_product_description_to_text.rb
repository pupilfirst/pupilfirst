class ChangeProductDescriptionToText < ActiveRecord::Migration
  def change
    change_column :startups, :product_description, :text
  end
end
