module OneOff
  # This service migrates data for stage 1 of the transition from 6-month program to continuous intake SaaS model.
  class SubscriptionStageOneMigrationService
    def execute
      update_chores_and_sessions
      level_startups
      upgrade_legacy_startups
      remove_stale_targets
    end

    private

    # Remove chores and sessions from target groups.
    def update_chores_and_sessions
      targets_with_group = Target.joins(:target_group)

      Rails.logger.info "Checking #{targets_with_group.count} targets for update..."

      targets_with_group.each do |target|
        # If target is a session or a chore, remove from target group.
        target.update!(target_group: nil) if target.session? || target.chore?
      end

      remove_empty_target_groups
    end

    def remove_empty_target_groups
      TargetGroup.includes(:targets).where(targets: { id: nil }).destroy_all
    end

    # Move startups to their appropriate level.
    def level_startups
      Rails.logger.info 'Levelling up startups...'

      Startup.where(batch: current_batch).each do |startup|
        while Startups::LevelUpEligibilityService.new(startup).eligible?
          Startups::LevelUpService.new(startup).execute
        end
      end
    end

    # Set iteration to 2 for startups from earlier batches.
    def upgrade_legacy_startups
      Rails.logger.info 'Upgrading legacy startups...'

      Startup.where.not(batch: current_batch).update_all(iteration: 2)
    end

    # Remove targets that don't belong to a group.
    def remove_stale_targets
      Rails.logger.info 'Removing stale targets...'

      targets_without_group = Target.includes(:target_group).where(target_groups: { id: nil })
      targets_without_group.destroy_all
    end

    def current_batch
      @current_batch ||= Batch.find_by(batch_number: 3)
    end
  end
end
