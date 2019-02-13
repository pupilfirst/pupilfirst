class RemoveLevelZeroStartups < ActiveRecord::Migration[5.2]
  def up
    Level.transaction do
      # Clear Level 0 contents
      target_groups = TargetGroup.joins(:level).where(levels: { number: 0 })
      targets = Target.where(target_group: target_groups)
      Quiz.where(target: targets).destroy_all
      TimelineEvent.where(target: targets).destroy_all
      targets.destroy_all
      target_groups.destroy_all

      # Clear all Level 0 members & their stuff
      founders = Founder.level_zero
      startups = Startup.level_zero
      KarmaPoint.where(startup: startups).destroy_all
      Payment.where(original_startup: startups).destroy_all
      Payment.where(startup: startups).destroy_all
      Payment.where(founder: founders).destroy_all
      TimelineEvent.from_founders(founders).destroy_all
      Founder.level_zero.destroy_all
      Startup.level_zero.destroy_all
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
