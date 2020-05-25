class AddLatestFlagToTimelineEventOwnersTable < ActiveRecord::Migration[6.0]
  def change
    add_column :timeline_event_owners, :latest, :boolean, default: false
  end
end
