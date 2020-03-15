class RemoveDescriptionAndLinksFromTimelineEvents < ActiveRecord::Migration[6.0]
  def change
    remove_column :timeline_events, :links, :text
    remove_column :timeline_events, :description, :text
  end
end
