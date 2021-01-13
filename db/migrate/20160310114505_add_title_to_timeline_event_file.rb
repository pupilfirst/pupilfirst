class AddTitleToTimelineEventFile < ActiveRecord::Migration[4.2]
  def change
    add_column :timeline_event_files, :title, :string
  end
end
