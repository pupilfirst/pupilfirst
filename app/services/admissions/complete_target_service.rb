module Admissions
  class CompleteTargetService
    def initialize(founder, key)
      @founder = founder
      @key = key
    end

    def execute
      target = Target.find_by(key: @key)

      timeline_event = target.timeline_events.create!(
        founder: @founder,
        startup: @founder.startup,
        description: description,
        timeline_event_type: timeline_event_type,
        event_on: Time.zone.now,
        iteration: @founder.startup.iteration
      )

      TimelineEvents::VerificationService.new(timeline_event).update_status(TimelineEvent::VERIFIED_STATUS_VERIFIED)
    end

    private

    def description
      case @key
        when Target::KEY_ADMISSIONS_SCREENING
          "#{@founder.name} has passed the screening stage of the SV.CO admissions process."
        when Target::KEY_ADMISSIONS_FOUNDER_EMAIL_VERIFICATION
          "#{@founder.name} has confirmed his email address by signing in."
        when Target::KEY_ADMISSIONS_FEE_PAYMENT
          "#{@founder.name} has paid the admission registration fee"
        when Target::KEY_ADMISSIONS_COFOUNDER_ADDITION
          "#{@founder.name} has added co-founders details"
        else
          raise "CompleteTargetService does not know how to generate description for #{@key}"
      end
    end

    def timeline_event_type
      if @key == Target::KEY_ADMISSIONS_FOUNDER_EMAIL_VERIFICATION
        TimelineEventType.find_by(key: TimelineEventType::TYPE_FOUNDER_UPDATE)
      else
        TimelineEventType.find_by(key: TimelineEventType::TYPE_TEAM_UPDATE)
      end
    end
  end
end
