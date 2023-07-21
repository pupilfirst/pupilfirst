class SetTargetPrerequisiteBetweenLevels < ActiveRecord::Migration[6.1]
  class Course < ApplicationRecord
    has_many :levels
    has_many :target_groups, through: :levels
    has_many :targets, through: :target_groups
  end

  class Level < ApplicationRecord
    belongs_to :course
    has_many :target_groups
    has_many :targets, through: :target_groups
  end

  class TargetGroup < ApplicationRecord
    belongs_to :level
    has_many :targets
  end

  class Target < ApplicationRecord
    belongs_to :target_group
    has_many :target_prerequisites, dependent: :destroy
    has_many :prerequisite_targets, through: :target_prerequisites

    VISIBILITY_LIVE = "live"
  end

  class TargetPrerequisite < ApplicationRecord
    belongs_to :target
    belongs_to :prerequisite_target, class_name: "Target"
  end

  def up
    courses = Course.all.includes(:levels, :target_groups, :targets)

    #  Assign lower level targets in a milestone as a prerequisite to next level milestone targets
    courses.each do |course|
      course
        .levels
        .order(number: :desc)
        .each do |level|
          level_number = level.number

          next if level_number.in?([0, 1])

          previous_level = course.levels.find_by(number: level_number - 1)

          previous_level_milestones =
            Target.where(
              target_group:
                TargetGroup.where(level: previous_level, milestone: true),
              visibility: Target::VISIBILITY_LIVE
            )

          level
            .target_groups
            .where(milestone: true)
            .order(:sort_index)
            .each do |target_group|
              target_group.targets.each do |target|
                target.prerequisite_targets << previous_level_milestones
              end
            end
        end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
