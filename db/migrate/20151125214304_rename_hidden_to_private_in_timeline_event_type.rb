class RenameHiddenToPrivateInTimelineEventType < ActiveRecord::Migration[4.2]
  def change
    rename_column :timeline_event_types, :hidden, :private
  end
end
