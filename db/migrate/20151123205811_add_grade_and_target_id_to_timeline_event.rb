class AddGradeAndTargetIdToTimelineEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :timeline_events, :grade, :string
    add_column :timeline_events, :target_id, :integer
    add_index :timeline_events, :target_id
  end
end
