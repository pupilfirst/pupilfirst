class TargetSkill < ApplicationRecord
  belongs_to :target
  belongs_to :skill

  validates :rubric, presence: true
  validates :base_karma_points, presence: true
end
