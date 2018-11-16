module Founders
  class RecordLatestSubmissionService
    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def execute
      timeline_event = @target.latest_linked_event(@founder)

      return if timeline_event.blank?

      submission_record = LatestSubmissionRecord.find_by(
        target: @target,
        founder: @founder
      ).present?

      return if submission_record.present?

      owners(timeline_event).each do |owner|
        LatestSubmissionRecord.where(
          founder_id: owner.id,
          target_id: timeline_event.target.id
        ).first_or_create!(
          timeline_event_id: timeline_event.id
        )
      end
    end

    private

    def owners(timeline_event)
      timeline_event.target.founder_role? ? [timeline_event.founder] : timeline_event.startup.founders
    end
  end
end
