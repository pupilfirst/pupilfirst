class FixTimelineEventTypeColumnName < ActiveRecord::Migration
  def change
    rename_column :timeline_events, :type, :event_type
  end
end
