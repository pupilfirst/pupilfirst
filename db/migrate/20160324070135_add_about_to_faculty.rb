class AddAboutToFaculty < ActiveRecord::Migration[4.2]
  def change
    add_column :faculty, :about, :text
  end
end
