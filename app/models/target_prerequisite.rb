class TargetPrerequisite < ApplicationRecord
  belongs_to :target
  belongs_to :prerequisite_target, class_name: 'Target'
end
