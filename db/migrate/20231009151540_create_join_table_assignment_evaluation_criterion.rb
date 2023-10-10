class CreateJoinTableAssignmentEvaluationCriterion < ActiveRecord::Migration[6.1]
  def change
    create_join_table :assignments, :evaluation_criteria do |t|
      t.index [:assignment_id, :evaluation_criterion_id], name: "index_assignment_evaluation_criterion"
      t.index [:evaluation_criterion_id, :assignment_id], name: "index_evaluation_criterion_assignment"
    end
  end
end
