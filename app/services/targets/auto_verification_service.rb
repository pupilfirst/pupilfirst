module Targets
  class AutoVerificationService
    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def auto_verify
      @target.timeline_events.create!(
        founders: [@founder],
        description: description,
        event_on: Time.zone.now,
        passed_at: Time.zone.now,
        latest: true
      )
    end

    private

    def description
      "Target '#{@target.title}' was auto-verified"
    end
  end
end
