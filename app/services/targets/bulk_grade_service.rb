module Targets
  class BulkGradeService
    def initialize(founder)
      @founder = founder
    end

    def grades
      @grades ||= begin
        founder_events = @founder.timeline_events.verified_or_needs_improvement.where.not(target_id: nil)
          .where(target: Target.founder)
          .select("DISTINCT ON(target_id) *").order("target_id, created_at DESC")

        startup_events = @founder.startup.timeline_events.verified_or_needs_improvement.where.not(target_id: nil)
          .where(target: Target.not_founder)
          .select("DISTINCT ON(target_id) *").order("target_id, created_at DESC")

        (founder_events + startup_events).each_with_object({}) do |event, result|
          result[event.target_id] = {
            grade: event.grade,
            event_id: event.id
          }
        end
      end
    end
  end
end
