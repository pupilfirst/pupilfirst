class AddArchivedAtToCourse < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :archived_at, :datetime
  end
end
