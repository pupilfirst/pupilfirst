class RemovePrivateFromTimelineEventType < ActiveRecord::Migration
  def change
    remove_column :timeline_event_types, :private, :boolean
  end
end
