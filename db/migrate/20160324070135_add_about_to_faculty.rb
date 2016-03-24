class AddAboutToFaculty < ActiveRecord::Migration
  def change
    add_column :faculty, :about, :text
  end
end
