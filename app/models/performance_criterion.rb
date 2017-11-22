class PerformanceCriterion < ApplicationRecord
  has_many :target_performance_criteria
  has_many :targets, through: :target_performance_criteria
end
