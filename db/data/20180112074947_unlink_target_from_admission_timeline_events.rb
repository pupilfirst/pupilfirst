class UnlinkTargetFromAdmissionTimelineEvents < ActiveRecord::Migration[5.1]
  def up
    five_days_ago = Time.now - 5.days
    timeline_events_to_update = TimelineEvent.from_level_0_startups.joins(:target)
      .where(targets: { key: [Target::KEY_ADMISSIONS_SCREENING, Target::KEY_ADMISSIONS_COFOUNDER_ADDITION] })
      .where('timeline_events.created_at < ?', five_days_ago)
    timeline_events_to_update.update_all(target_id: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
