class AddArchivedAtToFaculty < ActiveRecord::Migration[6.1]
  def change
    add_column :faculty, :archived_at, :datetime
  end
end
