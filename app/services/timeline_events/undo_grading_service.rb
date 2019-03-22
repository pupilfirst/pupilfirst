module TimelineEvents
  class UndoGradingService
    class ReviewPendingException < StandardError; end

    def initialize(timeline_event)
      @timeline_event = timeline_event
    end

    def execute
      raise ReviewPendingException unless @timeline_event.evaluator_id?

      TimelineEvent.transaction do
        # Clear existing grades
        TimelineEventGrade.where(timeline_event: @timeline_event).destroy_all
        # Clear evaluation info
        @timeline_event.update!(passed_at: nil, evaluator_id: nil)
      end
    end
  end
end
