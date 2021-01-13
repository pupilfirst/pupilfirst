class RemovePrivateFromTimelineEventType < ActiveRecord::Migration[4.2]
  def change
    remove_column :timeline_event_types, :private, :boolean
  end
end
