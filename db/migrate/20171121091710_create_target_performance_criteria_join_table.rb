class CreateTargetPerformanceCriteriaJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_table :target_performance_criteria do |t|
      t.references :target, foreign_key: true
      t.references :performance_criterion, foreign_key: true
      t.string :rubric_good
      t.string :rubric_great
      t.string :rubric_wow
      t.integer :base_karma_points

      t.timestamps
    end
  end
end
