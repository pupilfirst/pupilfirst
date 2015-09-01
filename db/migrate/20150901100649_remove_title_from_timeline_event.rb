class RemoveTitleFromTimelineEvent < ActiveRecord::Migration
  def change
    remove_column :timeline_events, :title, :string
  end
end
