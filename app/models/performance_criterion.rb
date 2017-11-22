class PerformanceCriterion < ApplicationRecord
  has_many :targets_performance_criteria
  has_many :targets, through: :targets_performance_criteria
end
