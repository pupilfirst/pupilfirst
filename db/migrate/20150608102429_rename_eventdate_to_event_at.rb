class RenameEventdateToEventAt < ActiveRecord::Migration
  def change
    rename_column :timeline_events, :eventdate, :event_at
  end
end
