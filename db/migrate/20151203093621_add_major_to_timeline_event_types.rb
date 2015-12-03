class AddMajorToTimelineEventTypes < ActiveRecord::Migration
  def change
    add_column :timeline_event_types, :major, :boolean
  end
end
