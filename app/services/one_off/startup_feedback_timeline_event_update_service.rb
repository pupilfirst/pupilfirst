module OneOff
  class StartupFeedbackTimelineEventUpdateService
    def execute
      all_startup_feedback = StartupFeedback.all
      all_startup_feedback.map do |startup_feedback|
        next if startup_feedback.timeline_event.blank?
        startup_feedback.update!(timeline_event_id: startup_feedback.timeline_event.id)
      end
    end
  end
end
