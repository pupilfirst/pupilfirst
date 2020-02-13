class AddChecklistResponseToTimelineEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :timeline_events, :checklist_response, :jsonb, default: []
  end
end
