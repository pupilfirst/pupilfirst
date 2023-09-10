class TargetPrerequisite < ApplicationRecord
  belongs_to :target
  belongs_to :prerequisite_target, class_name: "Target"
  validates_with RateLimitValidator, limit: 25, scope: :target_id
end
