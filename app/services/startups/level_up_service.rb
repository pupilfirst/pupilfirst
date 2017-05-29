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
      update = { level: next_level }
      update[:maximum_level] = next_level if next_level.number > @startup.maximum_level.number
      @startup.update!(update)
    end

    def next_level
      @next_level ||= Level.find_by(number: @startup.level.number + 1)
    end

    def enroll_for_level_one
      Startup.transaction do
        @startup.update!(level: next_level, program_started_on: Time.zone.now, maximum_level: next_level)

        @startup.timeline_events.create!(
          founder: @startup.admin,
          timeline_event_type: TimelineEventType.find_by(key: 'joined_svco'),
          event_on: Time.zone.now,
          iteration: @startup.iteration,
          description: event_description,
          status_updated_at: Time.zone.now,
          status: TimelineEvent::STATUS_VERIFIED
        )
      end
    end

    def event_description
      'We have successfully completed the admission process through Level 0. Excited to be part of the SV.CO tribe!'
    end
  end
end
