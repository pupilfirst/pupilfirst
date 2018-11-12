module TimelineEvents
  class GradingService
    def initialize(timeline_event)
      @timeline_event = timeline_event
    end

    def grade(faculty:, grades:)
      # TODO: validate grades

      TimelineEvent.transaction do
        @timeline_event.target_evaluation_criteria.each do |criterion|
          TimelineEventGrade.create!(
            timeline_event: @timeline_event,
            evaluation_criterion: criterion,
            grade: grades[criterion.id]
          )
        end

        @timeline_event.update!(
          evaluated_at: Time.now,
          evalautor: faculty
        )
      end
    end
  end
end
