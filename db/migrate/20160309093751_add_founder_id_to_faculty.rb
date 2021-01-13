class AddFounderIdToFaculty < ActiveRecord::Migration[4.2]
  def change
    add_column :faculty, :founder_id, :integer
  end
end
