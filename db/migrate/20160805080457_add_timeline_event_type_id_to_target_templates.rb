class AddTimelineEventTypeIdToTargetTemplates < ActiveRecord::Migration
  def change
    add_column :target_templates, :timeline_event_type_id, :integer
    add_index :target_templates, :timeline_event_type_id
  end
end
