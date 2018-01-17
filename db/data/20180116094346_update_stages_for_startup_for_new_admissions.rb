class UpdateStagesForStartupForNewAdmissions < ActiveRecord::Migration[5.1]
  def up
    startups_at_screening_stage = Startup.where(admission_stage: 'Screening Completed').where('created_at > ?', start_date_for_admissions)
    startups_at_screening_stage.update_all(admission_stage: Startup::ADMISSION_STAGE_SELF_EVALUATION_COMPLETED)
    startups_at_team_member_addition_stage = Startup.where(admission_stage: 'Added Cofounders').where('created_at > ?', start_date_for_admissions)
    startups_at_team_member_addition_stage.update_all(admission_stage: Startup::ADMISSION_STAGE_TEAM_MEMBERS_ADDED)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def start_date_for_admissions
    DateTime.new(2018, 1, 9)
  end
end
