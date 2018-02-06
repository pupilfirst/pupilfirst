class UpdateNullToFalseInTimelineEventTypeArchived < ActiveRecord::Migration[5.1]
  def up
    tet_collection = TimelineEventType.all
    tet_collection.each do |timeline_event_type|
      next unless timeline_event_type.archived.nil?
      timeline_event_type.update!(archived: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
