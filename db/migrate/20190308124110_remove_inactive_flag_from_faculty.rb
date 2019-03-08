class RemoveInactiveFlagFromFaculty < ActiveRecord::Migration[5.2]
  def change
    remove_column :faculty, :inactive
  end
end
