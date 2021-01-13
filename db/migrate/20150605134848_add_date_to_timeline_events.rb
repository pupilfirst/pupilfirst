class AddDateToTimelineEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :timeline_events, :eventdate, :date
  end
end
