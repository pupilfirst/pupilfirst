class AddSlugToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :slug, :string
    add_index :startups, :slug, unique: true
  end
end
