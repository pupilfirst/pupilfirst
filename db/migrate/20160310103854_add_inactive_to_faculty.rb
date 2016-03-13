class AddInactiveToFaculty < ActiveRecord::Migration
  def change
    add_column :faculty, :inactive, :boolean, default: false
  end
end
