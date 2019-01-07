class GradingOverhaulDatabaseChanges < ActiveRecord::Migration[5.2]
  def up
    change_column :timeline_event_grades, :grade, :integer, using: 'grade::integer'
    add_column :courses, :max_grade, :integer
    add_column :courses, :pass_grade, :integer
    add_reference :skills, :course
    remove_column :target_skills, :rubric_good
    remove_column :target_skills, :rubric_great
    remove_column :target_skills, :rubric_wow
    add_column :courses, :grade_labels, :json
    add_column :timeline_events, :evaluated, :boolean, default: false
    rename_table :skills, :evaluation_criteria
    rename_table :target_skills, :target_evaluation_criteria
    rename_column :target_evaluation_criteria, :skill_id, :evaluation_criterion_id
    rename_column :timeline_event_grades, :skill_id, :evaluation_criterion_id
    add_column :timeline_events, :evaluator_id, :integer
    add_foreign_key :timeline_events, :faculty, column: :evaluator_id
    remove_column :timeline_events, :evaluated, :boolean
    add_column :timeline_events, :evaluated_at, :datetime
    add_column :targets, :rubric_description, :text
    remove_column :target_evaluation_criteria, :base_karma_points, :integer
    remove_column :timeline_event_grades, :karma_points
    add_index :timeline_event_grades, [:timeline_event_id, :evaluation_criterion_id], unique: true, name: 'by_timeline_event_criterion'
    rename_column :timeline_events, :evaluated_at, :passed_at
    add_column :targets, :resubmittable, :boolean, default: true
    add_column :courses, :ends_at, :datetime
    create_table :timeline_event_owners do |t|
      t.references :timeline_event
      t.references :founder

      t.timestamps
    end
    add_column :timeline_events, :latest, :boolean
  end

  def down
    change_column :timeline_event_grades, :grade, :string
    rename_table :evaluation_criteria, :skills
    rename_table :target_evaluation_criteria, :target_skills
    rename_column :timeline_event_grades, :evaluation_criterion_id, :skill_id
    rename_column :target_skills, :evaluation_criterion_id, :skill_id
    remove_column :timeline_events, :evaluated_at, :datetime
    add_column :timeline_events, :evaluated, :boolean, default: false
    remove_column :timeline_events, :evaluator_id
  end
end
