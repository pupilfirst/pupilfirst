class AddIndexToCoachNoteArchivedAt < ActiveRecord::Migration[6.0]
  def change
    add_index :coach_notes, :archived_at
  end
end
