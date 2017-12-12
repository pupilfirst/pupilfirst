class TargetSkill < ApplicationRecord
  belongs_to :target
  belongs_to :skill

  validates :rubric_good, presence: true
  validates :rubric_great, presence: true
  validates :rubric_wow, presence: true
  validates :base_karma_points, presence: true
end
