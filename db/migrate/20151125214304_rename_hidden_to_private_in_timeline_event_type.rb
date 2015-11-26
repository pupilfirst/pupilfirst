class RenameHiddenToPrivateInTimelineEventType < ActiveRecord::Migration
  def change
    rename_column :timeline_event_types, :hidden, :private
  end
end
