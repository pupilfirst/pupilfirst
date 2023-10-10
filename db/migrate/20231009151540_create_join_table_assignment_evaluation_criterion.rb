class CreateJoinTableAssignmentEvaluationCriterion < ActiveRecord::Migration[6.1]
  def change
    create_join_table :assignments, :evaluation_criteria do |t|
      t.index [:assignment_id, :evaluation_criterion_id]
      t.index [:evaluation_criterion_id, :assignment_id]
    end
  end
end
