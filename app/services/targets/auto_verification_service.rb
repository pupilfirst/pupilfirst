module Targets
  class AutoVerificationService
    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def auto_verify
      @target.timeline_events.create!(
        founder: @founder,
        startup: @founder.startup,
        description: description,
        event_on: Time.zone.now,
        status: TimelineEvent::STATUS_VERIFIED
      )
    end

    private

    def description
      "Target '#{@target.title}' was auto-verified"
    end
  end
end
