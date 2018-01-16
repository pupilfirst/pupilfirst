class ResetStartupAdmissionStage < ActiveRecord::Migration[5.1]
  def up
    five_days_ago = Time.now - 5.days
    applicable_startups = Startup.level_zero.where('admission_stage_updated_at < ?', five_days_ago)

    applicable_startups.update_all(
      admission_stage: Startup::ADMISSION_STAGE_SIGNED_UP,
      admission_stage_updated_at: Time.now
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
