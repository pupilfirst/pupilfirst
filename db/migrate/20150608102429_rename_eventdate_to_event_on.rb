class RenameEventdateToEventOn < ActiveRecord::Migration
  def change
    rename_column :timeline_events, :eventdate, :event_on
  end
end
