class AddStatusToTimelineEvents < ActiveRecord::Migration
  def change
    add_column :timeline_events, :status, :string
  end
end
