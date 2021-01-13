class RenameEventdateToEventOn < ActiveRecord::Migration[4.2]
  def change
    rename_column :timeline_events, :eventdate, :event_on
  end
end
