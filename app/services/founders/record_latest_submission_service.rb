module Founders
  class RecordLatestSubmissionService
    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def execute(delete_candidate: nil)
      timeline_event = @target.latest_linked_event(@founder, exclude: delete_candidate)

      if delete_candidate.present? && timeline_event.blank?
        LatestSubmissionRecord.where(timeline_event: delete_candidate).delete_all
      else
        owners(timeline_event).each do |owner|
          LatestSubmissionRecord.where(
            founder_id: owner.id,
            target_id: timeline_event.target.id
          ).first_or_create!(
            timeline_event_id: timeline_event.id
          )
        end
      end
    end

    private

    def owners(timeline_event)
      timeline_event.target.founder_role? ? [timeline_event.founder] : timeline_event.startup.founders
    end
  end
end
