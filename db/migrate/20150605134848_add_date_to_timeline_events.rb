class AddDateToTimelineEvents < ActiveRecord::Migration
  def change
    add_column :timeline_events, :eventdate, :date
  end
end
