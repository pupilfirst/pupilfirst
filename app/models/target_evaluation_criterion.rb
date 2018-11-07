class TargetEvaluationCriterion < ApplicationRecord
  belongs_to :target
  belongs_to :evaluation_criterion

  validates :rubric, presence: true
  validates :base_karma_points, presence: true
end
