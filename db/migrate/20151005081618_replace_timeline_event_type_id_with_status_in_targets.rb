class ReplaceTimelineEventTypeIdWithStatusInTargets < ActiveRecord::Migration
  def up
    remove_column :targets, :timeline_event_type_id
    add_column :targets, :status, :string
  end

  def down
    add_column :targets, :timeline_event_type_id, :integer
    add_index :targets, :timeline_event_type_id
    remove_column :targets, :status
  end
end
