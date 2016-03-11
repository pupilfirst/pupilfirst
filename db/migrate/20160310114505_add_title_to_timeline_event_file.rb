class AddTitleToTimelineEventFile < ActiveRecord::Migration
  def change
    add_column :timeline_event_files, :title, :string
  end
end
