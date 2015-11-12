class AddSlugToResources < ActiveRecord::Migration
  def change
    add_column :resources, :slug, :string
    add_index :resources, :slug
  end
end
