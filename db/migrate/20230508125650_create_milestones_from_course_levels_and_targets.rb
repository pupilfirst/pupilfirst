class CreateMilestonesFromCourseLevelsAndTargets < ActiveRecord::Migration[6.1]
  def change
    courses = Course.all.includes(:levels, :target_groups, :targets)

    courses.each do |course|
      sort_index = 0
      course.levels.each do |level|
        level.target_groups.where(milestone: true).order(:sort_index).each do |target_group|
          milestone = Milestone.create!(sort_index: sort_index, name: target_group.name)
          sort_index += 1
          target_group.targets.each do |target|
            milestone.targets << target
          end
        end
      end
    end

  #  Assign lower level targets in a milestone as a prerequisit to next level milestone targets

    courses.each do |course|
      course.levels.order(number: :desc).each do |level|
        level_number = level.number

        next if level_number == 1

        previous_level = course.levels.find_by(number: level_number - 1)

        previous_level_milestones = Target.where(target_group: TargetGroup.where(level: previous_level, milestone: true))

        level.target_groups.where(milestone: true).order(:sort_index).each do |target_group|
          target_group.targets.each do |target|
            target.prerequisite_targets << previous_level_milestones
          end
        end
      end
    end
  end
end
