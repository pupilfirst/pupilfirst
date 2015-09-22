class RemoveIterationFromTimelineEvent < ActiveRecord::Migration
  def change
    remove_column :timeline_events, :iteration, :integer
  end
end
