class RenameNextEventToImprovedTimelineEvent < ActiveRecord::Migration
  def change
    rename_column :timeline_events, :next_event_id, :improved_timeline_event_id
  end
end
