module OneOff
  # This service migrates data for stage 1 of the transition from 6-month program to continuous intake SaaS model.
  class SubscriptionStageOneMigrationService
    include Loggable

    def execute
      add_level_to_startups
      update_chores_and_sessions
      level_startups
      upgrade_legacy_startups
      remove_stale_targets

      log 'All done!'
    end

    private

    def add_level_to_startups
      first_level = Level.find_by(number: 1)
      raise 'Could not find a level number 1. Have all levels been created properly?' if first_level.blank?
      startups_without_level = Startup.includes(:level).where(levels: { id: nil })

      if startups_without_level.any?
        log "There are #{startups_without_level.count} startups without level. Setting them to level 1..."
        startups_without_level.update(level: first_level)
      end
    end

    # Remove chores and sessions from target groups.
    def update_chores_and_sessions
      targets_with_group = Target.joins(:target_group)

      log "Checking #{targets_with_group.count} targets for update..."

      targets_with_group.each do |target|
        # If target is a session or a chore, remove from target group.
        target.update!(target_group: nil) if target.session? || target.chore?
      end

      remove_empty_target_groups
    end

    def remove_empty_target_groups
      empty_target_groups = TargetGroup.includes(:targets).where(targets: { id: nil })

      if empty_target_groups.any?
        log "Removing #{empty_target_groups.count} empty targets groups..."
        empty_target_groups.destroy_all
      end
    end

    # Move startups to their appropriate level.
    def level_startups
      log 'Levelling up startups...'

      Startup.where(batch: current_batch).each do |startup|
        while Startups::LevelUpEligibilityService.new(startup).eligible?
          log "Levelling up ##{startup.id} #{startup.name} to level #{startup.level.number + 1}..."
          Startups::LevelUpService.new(startup).execute
        end
      end
    end

    # Set iteration to 2 for startups from earlier batches.
    def upgrade_legacy_startups
      legacy_startups = Startup.where.not(batch: current_batch)

      if legacy_startups.any?
        log "Upgrading #{legacy_startups.count} legacy startups..."
        legacy_startups.update(iteration: 2)
      end
    end

    # Remove targets that don't belong to a group.
    def remove_stale_targets
      targets_without_group = Target.includes(:target_group).where(target_groups: { id: nil }, session_at: nil, chore: false)

      if targets_without_group.any?
        log "Removing #{targets_without_group.count} stale targets..."
        targets_without_group.destroy_all
      end
    end

    def current_batch
      @current_batch ||= Batch.find_by(batch_number: 3)
    end
  end
end
