class RemoveUnusedColumnsFromTimelineEvents < ActiveRecord::Migration[5.2]
  def change
    remove_column :timeline_events, :status
    remove_column :timeline_events, :status_updated_at
    remove_column :timeline_events, :founder_id
    remove_column :timeline_events, :startup_id
  end
end
