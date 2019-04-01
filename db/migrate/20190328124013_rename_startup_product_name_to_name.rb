class RenameStartupProductNameToName < ActiveRecord::Migration[5.2]
  def change
    rename_column :startups, :product_name, :name
  end
end
