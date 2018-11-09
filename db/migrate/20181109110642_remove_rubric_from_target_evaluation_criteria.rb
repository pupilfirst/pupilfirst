class RemoveRubricFromTargetEvaluationCriteria < ActiveRecord::Migration[5.2]
  def change
    remove_column :target_evaluation_criteria, :rubric, :json
    remove_column :target_evaluation_criteria, :base_karma_points, :integer
  end
end
