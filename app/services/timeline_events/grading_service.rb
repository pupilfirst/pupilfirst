module TimelineEvents
  class GradingService
    def initialize(timeline_event)
      @timeline_event = timeline_event
    end

    # @param faculty [Faculty] Faculty who is evaluating the timeline event.
    # @param grades [Hash] Grades in this format: {evaluation_criterion_id: grade_integer, ...}
    def grade(faculty, grades)
      raise TimelineEvents::GradingService::NotGradableException if evaluation_criteria.blank?
      raise TimelineEvents::GradingService::InvalidGradesException unless valid_grading?(grades)

      TimelineEvent.transaction do
        evaluation_criteria.each do |criterion|
          TimelineEventGrade.create!(
            timeline_event: @timeline_event,
            evaluation_criterion: criterion,
            grade: grades[criterion.id]
          )
        end

        @timeline_event.update!(
          passed_at: (failed?(grades) ? nil : Time.now),
          evaluator: faculty
        )
      end
    end

    private

    def evaluation_criteria
      @evaluation_criteria ||= @timeline_event.evaluation_criteria.to_a
    end

    def valid_grading?(grades)
      return false unless grades.is_a? Hash

      all_criteria_graded?(grades) && all_grades_valid?(grades)
    end

    def all_criteria_graded?(grades)
      evaluation_criteria.map(&:id).sort == grades.keys.sort
    end

    def all_grades_valid?(grades)
      grades.values.all? { |grade| grade.in?(1..max_grade) }
    end

    def max_grade
      @max_grade ||= @timeline_event.founder.school.max_grade
    end

    def pass_grade
      @pass_grade ||= @timeline_event.founder.school.pass_grade
    end

    def failed?(grades)
      grades.values.any? { |grade| grade < pass_grade }
    end
  end
end
