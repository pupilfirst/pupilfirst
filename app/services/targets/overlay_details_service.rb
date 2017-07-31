module Targets
  class OverlayDetailsService
    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def all_details
      {
        founderStatuses: founder_statuses,
        latestEvent: latest_event,
        latestFeedback: latest_feedback
      }
    end

    def founder_statuses
      return nil unless @target.founder_role?

      @founder.startup.founders.not_exited.each_with_object([]) do |founder, statuses|
        statuses << { founder.id => Targets::StatusService.new(@target, founder).status }
      end
    end

    def latest_event
      @target.latest_linked_event(@founder).as_json(
        only: %i[description event_on],
        methods: %i[title days_elapsed]
      )
    end

    def latest_feedback
      Targets::FeedbackService.new(@target, @founder).latest_feedback_details
    end
  end
end
