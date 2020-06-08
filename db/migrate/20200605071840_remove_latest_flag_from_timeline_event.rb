class RemoveLatestFlagFromTimelineEvent < ActiveRecord::Migration[6.0]
  def change
    remove_column :timeline_events, :latest
    remove_column :timeline_events, :improved_timeline_event_id
  end
end
