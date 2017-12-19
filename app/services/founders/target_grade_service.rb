module Founders
  class TargetGradeService
    def initialize(founder)
      @founder = founder
    end

    def grade(target_id)
      grades[target_id][:grade]
    end

    def score(target_id)
      grades[target_id][:score]
    end

    private

    def grades
      @grades ||= begin
        founder_events = @founder.timeline_events.verified_or_needs_improvement.where.not(target_id: nil)
          .where(target: Target.founder)
          .select('DISTINCT ON(target_id) *').order('target_id, created_at DESC')

        startup_events = @founder.startup.timeline_events.verified_or_needs_improvement.where.not(target_id: nil)
          .where(target: Target.not_founder)
          .select('DISTINCT ON(target_id) *').order('target_id, created_at DESC')

        (founder_events + startup_events).each_with_object({}) do |event, result|
          result[event.target_id] = {
            grade: score_to_grade(event.score),
            event_id: event.id,
            score: event.score
          }
        end
      end
    end

    def score_to_grade(score)
      return if score.blank?
      { 1 => 'good', 2 => 'great', 3 => 'wow' }[score.floor]
    end
  end
end
