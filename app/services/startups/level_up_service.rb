module Startups
  # This service should be used to upgrade a startup to the next level.
  class LevelUpService
    def initialize(startup)
      @startup = startup
    end

    def execute
      if next_level.present?
        next_level.number == 1 ? enroll_for_level_one : level_up
      else
        raise 'Maximum level reached - cannot level up.'
      end
    end

    private

    def level_up
      @startup.update!(level: next_level)
    end

    def course
      @course ||= @startup.level.course
    end

    def next_level
      @next_level ||= course.levels.find_by(number: @startup.level.number + 1)
    end

    def enroll_for_level_one
      Startup.transaction do
        @startup.update!(level: next_level, program_started_on: Time.zone.now)

        # Update the admission stage for the startup entry.
        Admissions::UpdateStageService.new(@startup, Startup::ADMISSION_STAGE_ADMITTED).execute
      end

      # Tag all founders on Intercom as 'Moved to Level 1'.
      @startup.founders.not_exited.each do |founder|
        Intercom::FounderTaggingJob.perform_later(founder, 'Moved to Level 1')
      end

      # On Intercom, update the admission stage the team lead of startup.
      Intercom::LevelZeroStageUpdateJob.perform_later(@startup.team_lead, Startup::ADMISSION_STAGE_ADMITTED)
    end

    def event_description
      'The team has successfully completed Level 0 and joined the Startup Village Collective.'
    end
  end
end
