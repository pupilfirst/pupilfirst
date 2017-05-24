module Targets
  class FeedbackService
    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def latest_feedbacks
      return if latest_timeline_event&.startup_feedback.blank?
      latest_timeline_event.startup_feedback
    end

    private

    def latest_timeline_event
      Targets::StatusService.new(@target, @founder).linked_event
    end
  end
end
