class AddBadgeToTimelineEventTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :timeline_event_types, :badge, :string
  end
end
