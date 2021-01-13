class RemoveIterationFromTimelineEvent < ActiveRecord::Migration[4.2]
  def change
    remove_column :timeline_events, :iteration, :integer
  end
end
