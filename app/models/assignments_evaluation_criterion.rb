class AssignmentsEvaluationCriterion < ApplicationRecord
  acts_as_copy_target

  belongs_to :assignment
  belongs_to :evaluation_criterion
end
