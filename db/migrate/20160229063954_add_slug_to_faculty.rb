class AddSlugToFaculty < ActiveRecord::Migration[4.2]
  def change
    add_column :faculty, :slug, :string
    add_index :faculty, :slug, unique: true
  end
end
