module OneOff
  class StartupFeedbackTimelineEventUpdateService
    include Loggable

    REGEX_TIMELINE_EVENT_URL = %r{startups/.*event-(?<event_id>[\d]+)}

    def execute
      all_startup_feedback = StartupFeedback.all
      updated_records_count = 0
      all_startup_feedback.map do |startup_feedback|
        next if startup_feedback.timeline_event.present?
        next if startup_feedback.reference_url.match(REGEX_TIMELINE_EVENT_URL).blank?
        timeline_event_id = timeline_event_id(startup_feedback.reference_url)
        next if TimelineEvent.where(id: timeline_event_id).blank?

        startup_feedback.update!(timeline_event_id: timeline_event_id)
        updated_records_count += 1
        log "#{updated_records_count} records updated!"
      end
    end

    private

    def timeline_event_id(reference_url)
      reference_url.match(REGEX_TIMELINE_EVENT_URL)[:event_id]
    end
  end
end
