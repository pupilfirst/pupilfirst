class SetTargetMilestoneFromTargetGroup < ActiveRecord::Migration[6.1]
  def up
    target_groups = TargetGroup.where(milestone: true).includes(:targets)

    target_groups.each do |target_group|
      target_group.targets.update_all(milestone: true)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
