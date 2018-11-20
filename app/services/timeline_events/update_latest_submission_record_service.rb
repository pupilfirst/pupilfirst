module TimelineEvents
  # This service updates the latest submission record for each founder in a startup given a timeline event
  class UpdateLatestSubmissionRecordService
    def initialize(timeline_event)
      @timeline_event = timeline_event
    end

    def execute
      owners.each do |owner|
        record = LatestSubmissionRecord.where(
          founder: owner,
          target: @timeline_event.target
        ).first_or_create!(
          timeline_event: @timeline_event
        )

        record.update!(timeline_event: @timeline_event) if record.timeline_event != @timeline_event
      end
    end

    private

    def owners
      @timeline_event.target.founder_role? ? [@timeline_event.founder] : @timeline_event.startup.founders
    end
  end
end
