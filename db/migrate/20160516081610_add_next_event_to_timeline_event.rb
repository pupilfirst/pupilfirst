class AddNextEventToTimelineEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :timeline_events, :next_event_id, :integer
  end
end
