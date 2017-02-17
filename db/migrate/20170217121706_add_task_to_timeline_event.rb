class AddTaskToTimelineEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :timeline_events, :task_type, :string
    rename_column :timeline_events, :target_id, :task_id
  end
end
