class AddHiddenToTimelineEventType < ActiveRecord::Migration[4.2]
  def change
    add_column :timeline_event_types, :hidden, :boolean
  end
end
