module Targets
  class FeedbackService
    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def feedback_for_latest_event
      @target.latest_linked_event(@founder).startup_feedback.order('created_at').last
    end

    private

    def latest_timeline_event
      Targets::StatusService.new(@target, @founder).linked_event
    end
  end
end
