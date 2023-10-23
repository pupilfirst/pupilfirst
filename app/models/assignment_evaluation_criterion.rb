class AssignmentEvaluationCriterion < ApplicationRecord
  #TODO - figure out what is wrong with automatic table name
  self.table_name = "assignments_evaluation_criteria"
  belongs_to :assignment
  belongs_to :evaluation_criterion
end
