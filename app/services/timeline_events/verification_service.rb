module TimelineEvents
  class VerificationService
    attr_reader :timeline_event, :target, :grade

    def initialize(timeline_event)
      @timeline_event = timeline_event
      @target = @timeline_event.target
    end

    def verify(grade: nil)
      @grade = grade

      TimelineEvent.transaction do
        timeline_event.verify!
        update_karma_points
      end
    end

    private

    def update_karma_points
      return unless points_for_target.present?

      KarmaPoint.transaction do
        remove_previous_points if target.present?
        add_karma_points
      end
    end

    def remove_previous_points
      KarmaPoint.where(source: target.timeline_events).delete_all
    end

    def add_karma_points
      KarmaPoint.create!(
        source: timeline_event,
        founder: founder,
        startup: timeline_event.startup,
        activity_type: "Added a new Timeline event - #{timeline_event.title}",
        points: applicable_points
      )
    end

    def founder
      timeline_event.founder_event? ? timeline_event.founder : nil
    end

    def applicable_points
      return points_for_target unless grade.present?

      points_for_target * grade_multiplier(grade)
    end

    def grade_multiplier(grade)
      {
        TimelineEvent::GRADE_GOOD => 1,
        TimelineEvent::GRADE_GREAT => 1.5,
        TimelineEvent::GRADE_WOW => 2
      }.with_indifferent_access[grade]
    end

    def points_for_target
      @points_for_target ||= timeline_event&.target&.points_earnable
    end
  end
end
