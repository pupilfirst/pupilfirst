class AddNextEventToTimelineEvent < ActiveRecord::Migration
  def change
    add_column :timeline_events, :next_event_id, :integer
  end
end
