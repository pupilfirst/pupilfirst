module OneOff
  # This service migrates data for stage 1 of the transition from 6-month program to continuous intake SaaS model.
  class SubscriptionStageOneMigrationService
    def execute
      move_targets
      level_startups
      upgrade_legacy_startups
      remove_stale_targets
    end

    private

    # Create sessions and chores for all marked targets
    def move_targets
      targets_with_group = Target.joins(:target_group)

      targets_with_group.each do |target|
        if target.session_at.present?
          create_session(target)
        elsif target.chore?
          create_chore(target)
        end

        target.destroy!
      end

      remove_empty_target_groups
    end

    def create_session(target)
      # Create a session.
      # link_timeline_events(target, session)
      # link_prerequisites(target, session)
    end

    def create_chore(target)
      # Create a chore.
      # link_timeline_events(target, session)
      # link_prerequisites(target, session)
    end

    def link_timeline_events(target, session)
    end

    def link_prerequisites(target, session)
    end

    def remove_empty_target_groups
    end

    # Move startups to their appropriate level.
    def level_startups
    end

    # Set iteration to 2 for startups from earlier batches.
    def upgrade_legacy_startups
      Rails.logger.info 'upgrade_legacy_startups: Begin.'

      Startup.where.not(batch: current_batch).update_all(iteration: 2)

      Rails.logger.info 'upgrade_legacy_startups: Done.'
    end

    # Remove targets that don't belong to a group.
    def remove_stale_targets
      Rails.logger.info 'remove_stale_targets: Begin.'

      targets_without_group = Target.includes(:target_group).where(target_groups: { id: nil })
      targets_without_group.destroy_all

      Rails.logger.info 'remove_stale_targets: Done.'
    end

    def current_batch
      @current_batch ||= Batch.find_by(batch_number: 3)
    end
  end
end
