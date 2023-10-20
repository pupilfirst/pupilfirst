class AssignmentEvaluationCriterion < ApplicationRecord
  self.table_name = "assignments_evaluation_criteria"
  belongs_to :assignment
  belongs_to :evaluation_criterion
end
