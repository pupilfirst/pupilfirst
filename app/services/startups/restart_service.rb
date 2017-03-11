module Startups
  # This service should be used to handle restart button clicks on the founder dashboard. Founders are allowed to
  # restart to any level >= 2 and less than the startup's level. Restarting also requires the founder to supply a
  # reason, which is used to create an 'end_iteration' timeline event.
  class RestartService
    LevelInvalid = Class.new(StandardError)

    def initialize(startup, founder)
      @startup = startup
      @founder = founder
    end

    def restart(level, reason)
      raise LevelInvalid if level.number < 2 || !(level.number < @startup.level.number)

      Startup.transaction do
        # Create a timeline event to mark this.
        @startup.timeline_events.create!(
          founder: @founder,
          description: reason,
          timeline_event_type: TimelineEventType.end_iteration,
          event_on: Time.zone.now
        )

        # Increment iteration and set new level.
        @startup.update!(iteration: @startup.iteration + 1, level: level)
      end
    end
  end
end
