class RemoveTitleFromTimelineEvent < ActiveRecord::Migration[4.2]
  def change
    remove_column :timeline_events, :title, :string
  end
end
