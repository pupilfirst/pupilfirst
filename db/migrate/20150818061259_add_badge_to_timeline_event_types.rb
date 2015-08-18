class AddBadgeToTimelineEventTypes < ActiveRecord::Migration
  def change
    add_column :timeline_event_types, :badge, :string
  end
end
