class AddLatestToTimelineEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :timeline_events, :latest, :boolean
  end
end
