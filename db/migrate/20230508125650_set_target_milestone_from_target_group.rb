class SetTargetMilestoneFromTargetGroup < ActiveRecord::Migration[6.1]
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
                .where(milestone: true)
                .order(:sort_index)
                .each do |target_group|
                  target_group
                    .targets
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
