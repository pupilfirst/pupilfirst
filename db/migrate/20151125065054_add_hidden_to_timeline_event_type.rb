class AddHiddenToTimelineEventType < ActiveRecord::Migration
  def change
    add_column :timeline_event_types, :hidden, :boolean
  end
end
