class RemoveEventTypeFromTimelineEvents < ActiveRecord::Migration
  def change
    remove_column :timeline_events, :event_type, :string
  end
end
