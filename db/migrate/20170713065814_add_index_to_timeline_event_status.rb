class AddIndexToTimelineEventStatus < ActiveRecord::Migration[5.1]
  def change
    add_index :timeline_events, :status
  end
end
