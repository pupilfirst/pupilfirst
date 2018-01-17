module Admissions
  class CompleteTargetService
    def initialize(founder, key)
      @founder = founder
      @key = key
    end

    def execute
      target = Target.find_by(key: @key)

      # Do not complete an admissions target twice.
      return if target.status(@founder) == Targets::StatusService::STATUS_COMPLETE

      timeline_event = target.timeline_events.create!(
        founder: @founder,
        startup: @founder.startup,
        description: description,
        timeline_event_type: team_update,
        event_on: Time.zone.now,
        iteration: @founder.startup.iteration
      )

      TimelineEvents::VerificationService.new(timeline_event, notify: false)
        .update_status(TimelineEvent::STATUS_VERIFIED)

      if @key.in?([Target::KEY_ADMISSIONS_SCREENING, Target::KEY_ADMISSIONS_FEE_PAYMENT, Target::KEY_ADMISSIONS_COFOUNDER_ADDITION])
        Admissions::UpdateStageService.new(@founder.startup, admission_stage).execute
      end
    end

    private

    def description
      case @key
        when Target::KEY_ADMISSIONS_SCREENING
          "#{@founder.name} has completed the screening target of SV.CO's Level 0."
        when Target::KEY_ADMISSIONS_FEE_PAYMENT
          "#{@founder.name} just completed payment to join the SV.CO program."
        when Target::KEY_ADMISSIONS_COFOUNDER_ADDITION
          "#{@founder.name} has invited co-founders to join their startup."
        else
          raise "CompleteTargetService does not know how to generate description for #{@key}"
      end
    end

    def team_update
      TimelineEventType.find_by(key: TimelineEventType::TYPE_TEAM_UPDATE)
    end

    def admission_stage
      case @key
        when Target::KEY_ADMISSIONS_SCREENING
          Startup::ADMISSION_STAGE_SELF_EVALUATION_COMPLETED
        when Target::KEY_ADMISSIONS_COFOUNDER_ADDITION
          Startup::ADMISSION_STAGE_TEAM_MEMBERS_ADDED
        when Target::KEY_ADMISSIONS_FEE_PAYMENT
          Startup::ADMISSION_STAGE_FEE_PAID
      end
    end
  end
end
