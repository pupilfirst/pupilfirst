class RemoveTimelineEventsWithMissingTarget < ActiveRecord::Migration[6.1]
  def up
    te_missing_targets = TimelineEvent.includes(:target).where('targets.id IS NULL').references(:target)
    puts "Destroying #{te_missing_targets.count} timeline events with missing targets"
    te_missing_targets.destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
