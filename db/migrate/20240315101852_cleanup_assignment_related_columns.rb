class CleanupAssignmentRelatedColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :targets, :role, :string
    remove_column :targets, :completion_instructions, :string
    remove_column :targets, :milestone, :boolean, default: false
    remove_column :targets, :milestone_number, :integer
    remove_column :targets, :checklist, :jsonb, default: []

    remove_reference :quizzes,
                     :target,
                     foreign_key: true,
                     index: {
                       unique: true
                     }

    drop_table :target_prerequisites do |t|
      t.integer "target_id"
      t.integer "prerequisite_target_id"
      t.index "prerequisite_target_id"
      t.index "target_id"
    end

    drop_table :target_evaluation_criteria do |t|
      t.references :target, foreign_key: true
      t.references :evaluation_criterion, foreign_key: true
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end

    remove_column :target_groups, :milestone, :boolean
  end
end
