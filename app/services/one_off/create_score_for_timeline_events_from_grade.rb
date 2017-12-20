module OneOff
  class CreateScoreForTimelineEventsFromGrade
    include Loggable
    def execute
      verified_events_with_grade = TimelineEvent.verified.where.not(grade: nil)
      verified_events_with_grade.each do |event|
        event.update!(score: grade_to_score[event.grade])
      end
    end

    private

    def grade_to_score
      @grade_to_score ||= { TimelineEvent::GRADE_GOOD => 1.0, TimelineEvent::GRADE_GREAT => 2.0, TimelineEvent::GRADE_WOW => 3.0 }
    end
  end
end
