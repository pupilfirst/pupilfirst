module TimelineEvents
  class VerificationService
    def initialize(timeline_event)
      @timeline_event = timeline_event
      @target = @timeline_event.target
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def update_status(status, grade: nil, points: nil)
      raise 'Unexpected grade specified' unless grade.blank? || grade.in?(TimelineEvent.valid_grades)

      @grade = grade
      @points = points
      @timeline_event.update!(grade: @grade)
      @new_status = status

      case @new_status
        when TimelineEvent::VERIFIED_STATUS_VERIFIED then mark_verified
        when TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT then mark_needs_improvement
        when TimelineEvent::VERIFIED_STATUS_NOT_ACCEPTED then mark_not_accepted
        when TimelineEvent::VERIFIED_STATUS_PENDING then mark_pending
        else raise 'Unexpected status specified!'
      end

      TimelineEventVerificationNotificationJob.perform_later @timeline_event

      [@timeline_event, applicable_points]
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    private

    def mark_verified
      TimelineEvent.transaction do
        @timeline_event.verify!
        update_karma_points
      end
    end

    def mark_needs_improvement
      TimelineEvent.transaction do
        @timeline_event.mark_needs_improvement!
        update_karma_points
      end
    end

    def mark_not_accepted
      TimelineEvent.transaction do
        @timeline_event.mark_not_accepted!
        reset_karma_points
      end
    end

    def mark_pending
      TimelineEvent.transaction do
        @timeline_event.revert_to_pending!
        reset_karma_points
      end
    end

    def update_karma_points
      return unless @points.present? || points_for_target.present?

      reset_karma_points
      add_karma_points
    end

    def reset_karma_points
      KarmaPoint.where(source: @timeline_event).delete_all
      remove_previous_points_for_target if @target.present?
    end

    def remove_previous_points_for_target
      founder = @timeline_event.founder
      target_timeline_events_from_founder = @target.timeline_events.where(founder: founder)
      KarmaPoint.where(source: target_timeline_events_from_founder).delete_all
    end

    def add_karma_points
      KarmaPoint.create!(
        source: @timeline_event,
        founder: founder,
        startup: @timeline_event.startup,
        activity_type: "Added a new Timeline event - #{@timeline_event.title}",
        points: applicable_points
      )
    end

    def founder
      @timeline_event.founder_event? ? @timeline_event.founder : nil
    end

    def applicable_points
      return @points if @points.present?
      return nil if @points&.empty?

      return nil unless @new_status.in?([TimelineEvent::VERIFIED_STATUS_VERIFIED, TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT])
      return points_for_target unless @grade.present? && @new_status == TimelineEvent::VERIFIED_STATUS_VERIFIED

      points_for_target * grade_multiplier
    end

    def grade_multiplier
      {
        TimelineEvent::GRADE_GOOD => 1,
        TimelineEvent::GRADE_GREAT => 1.5,
        TimelineEvent::GRADE_WOW => 2
      }.with_indifferent_access[@grade]
    end

    def points_for_target
      @points_for_target ||= @target&.points_earnable
    end
  end
end
