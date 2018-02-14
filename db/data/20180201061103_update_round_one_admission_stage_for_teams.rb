class UpdateRoundOneAdmissionStageForTeams < ActiveRecord::Migration[5.1]
  def up
    verified_timeline_events.joins(:target).where(targets: { key: [Target::KEY_R1_TASK, Target::KEY_R1_SHOW_PREVIOUS_WORK] }).each do |te|
      te.startup.update!(admission_stage: Startup::ADMISSION_STAGE_R1_TASK_PASSED, admission_stage_updated_at: te.status_updated_at)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def verified_timeline_events
    @verified_timeline_events ||= TimelineEvent.where(status: TimelineEvent::STATUS_VERIFIED)
  end
end
