class RemoveIndexFromTimeLineEventTypeSuggestedStage < ActiveRecord::Migration
  def change
    remove_index :timeline_event_types, :suggested_stage
  end
end
