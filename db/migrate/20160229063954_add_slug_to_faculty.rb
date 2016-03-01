class AddSlugToFaculty < ActiveRecord::Migration
  def change
    add_column :faculty, :slug, :string
    add_index :faculty, :slug, unique: true
  end
end
