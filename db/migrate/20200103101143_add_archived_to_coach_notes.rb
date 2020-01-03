class AddArchivedToCoachNotes < ActiveRecord::Migration[6.0]
  def change
    add_column :coach_notes, :archived_at, :datetime
  end
end
