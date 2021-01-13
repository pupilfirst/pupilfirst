class AddSuggestedStageToTimelineEventType < ActiveRecord::Migration[4.2]
  def change
    add_column :timeline_event_types, :suggested_stage, :string
    add_index :timeline_event_types, :suggested_stage
  end
end
