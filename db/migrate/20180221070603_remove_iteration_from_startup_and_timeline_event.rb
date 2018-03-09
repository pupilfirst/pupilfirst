class RemoveIterationFromStartupAndTimelineEvent < ActiveRecord::Migration[5.1]
  def change
    remove_column :startups, :iteration, :integer
    remove_column :timeline_events, :iteration, :integer
  end
end
