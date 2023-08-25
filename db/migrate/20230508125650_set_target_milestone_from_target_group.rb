class SetTargetMilestoneFromTargetGroup < ActiveRecord::Migration[6.1]
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

    VISIBILITY_LIVE = "live"
  end

  def up
    ActiveRecord::Base.transaction do
      Course
        .includes(:levels, :target_groups, :targets)
        .find_each do |course|
          milestone_number = 0

          course
            .levels
            .order(:number)
            .each do |level|
              level
                .target_groups
                .where(milestone: true, archived: false)
                .order(:sort_index)
                .each do |target_group|
                  target_group
                    .targets
                    .where(visibility: Target::VISIBILITY_LIVE)
                    .order(:sort_index)
                    .each do |target|
                      milestone_number += 1
                      target.update(
                        milestone: true,
                        milestone_number: milestone_number
                      )
                    end
                end
            end
        end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
