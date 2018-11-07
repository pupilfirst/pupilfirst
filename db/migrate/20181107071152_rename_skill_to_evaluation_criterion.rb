class RenameSkillToEvaluationCriterion < ActiveRecord::Migration[5.2]
  def up
    rename_table :skills, :evaluation_criteria
    rename_table :target_skills, :target_evaluation_criteria
    rename_column :target_evaluation_criteria, :skill_id, :evaluation_criterion_id
    rename_column :timeline_event_grades, :skill_id, :evaluation_criterion_id
  end

  def down
    rename_table :evaluation_criteria, :skills
    rename_table :target_evaluation_criteria, :target_skills
    rename_column :timeline_event_grades, :evaluation_criterion_id, :skill_id
    rename_column :target_skills, :evaluation_criterion_id, :skill_id
  end
end
