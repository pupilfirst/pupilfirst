class RestoreTargetToTimelineEvent < ActiveRecord::Migration[5.0]
  def change
    rename_column :timeline_events, :task_id, :target_id
    remove_column :timeline_events, :task_type
  end
end
