class RemoveTimelineTouredFromFounder < ActiveRecord::Migration[5.0]
  def change
    remove_column :founders, :timeline_toured, :boolean
  end
end
