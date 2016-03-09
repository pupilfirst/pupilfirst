class AddFounderIdToFaculty < ActiveRecord::Migration
  def change
    add_column :faculty, :founder_id, :integer
  end
end
