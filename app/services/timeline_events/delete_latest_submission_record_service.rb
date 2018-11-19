module TimelineEvents
  # This service destroys the latest submission record for a given timeline event
  # and updates the LatestSubmissionRecord if a previous submission exist.
  class DeleteLatestSubmissionRecordService
    def initialize(timeline_event)
      @timeline_event = timeline_event
    end

    def execute
      LatestSubmissionRecord.where(timeline_event: @timeline_event).destroy_all
      linked_timeline_event = @timeline_event.target.latest_linked_event(@timeline_event.founder, exclude: @timeline_event)

      if linked_timeline_event.present?
        TimelineEvents::UpdateLatestSubmissionRecordService.new(linked_timeline_event).execute
      end
    end
  end
end
