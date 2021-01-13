class AddSlugToResources < ActiveRecord::Migration[4.2]
  def change
    add_column :resources, :slug, :string
    add_index :resources, :slug
  end
end
