class FixTimelineEventTypeColumnName < ActiveRecord::Migration[4.2]
  def change
    rename_column :timeline_events, :type, :event_type
  end
end
