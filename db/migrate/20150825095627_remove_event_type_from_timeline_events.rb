class RemoveEventTypeFromTimelineEvents < ActiveRecord::Migration[4.2]
  def change
    remove_column :timeline_events, :event_type, :string
  end
end
