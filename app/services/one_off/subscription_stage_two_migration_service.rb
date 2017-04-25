module OneOff
  # This service migrates data for stage 2 of the transition from 6-month program to continuous intake model.
  class SubscriptionStageTwoMigrationService
    include Loggable

    def execute
      set_startup_maximum_level
      set_submittability_for_main_targets
      set_level_for_faculty
      set_level_for_resources
      set_program_started_on_for_startups

      log 'All done!'
    end

    private

    def set_startup_maximum_level
      Startup.all.each do |startup|
        startup.update!(maximum_level: startup.level)
      end
    end

    def set_submittability_for_main_targets
      Target.joins(:level).where('levels.number >= ?', 1).each do |target|
        target.update!(submittability: Target::SUBMITTABILITY_RESUBMITTABLE)
      end
    end

    def set_level_for_faculty
      Faculty.joins(:connect_slots).each do |faculty|
        faculty.update!(level: level_one)
      end
    end

    def set_level_for_resources
      Resource.where.not(share_status: 'public').where(startup_id: nil).each do |resource|
        resource.update!(level: level_one)
      end
    end

    def set_program_started_on_for_startups
      Startup.where.not(batch_id: nil).each do |startup|
        startup.update!(program_started_on: startup.batch.start_date)
      end
    end

    def level_one
      @level_one ||= Level.find_by(number: 1)
    end
  end
end
