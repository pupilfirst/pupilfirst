module TimelineEvents
  class GradingService
    class AlreadyReviewedException < StandardError; end

    def initialize(timeline_event)
      @timeline_event = timeline_event
    end

    # @param faculty [Faculty] Faculty who is evaluating the timeline event.
    # @param grades [Hash] Grades in this format: {evaluation_criterion_id: grade_integer, ...}
    def grade(faculty, grades)
      raise AlreadyReviewedException if @timeline_event.reviewed?
      raise "Cannot grade TimelineEvent##{@timeline_event.id} without evaluation criteria" if evaluation_criteria.blank?
      raise "Grading values supplied are invalid: #{grades.to_json}" unless valid_grading?(grades)

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
          evaluator: faculty,
          evaluated_at: Time.now
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
      grades.all? { |ec_id, grade| grade.in?(1..EvaluationCriterion.find(ec_id).max_grade) }
    end

    def failed?(grades)
      grades.any? { |ec_id, grade| grade < EvaluationCriterion.find(ec_id).pass_grade }
    end
  end
end
