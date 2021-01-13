class AddInactiveToFaculty < ActiveRecord::Migration[4.2]
  def change
    add_column :faculty, :inactive, :boolean, default: false
  end
end
