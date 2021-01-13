class RemoveIndexFromTimeLineEventTypeSuggestedStage < ActiveRecord::Migration[4.2]
  def change
    remove_index :timeline_event_types, :suggested_stage
  end
end
