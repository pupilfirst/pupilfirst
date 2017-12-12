class RenamePerformanceCriteriaToSkills < ActiveRecord::Migration[5.1]
  def change
    rename_table :performance_criteria, :skills
    rename_table :target_performance_criteria, :target_skills
    rename_column :target_skills, :performance_criterion_id, :skill_id
    rename_column :timeline_event_grades, :performance_criterion_id, :skill_id
  end
end
