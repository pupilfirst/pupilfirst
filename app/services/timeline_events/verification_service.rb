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
        when TimelineEvent::VERIFIED_STATUS_VERIFIED
          mark_verified
        when TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT
          mark_needs_improvement
        when TimelineEvent::VERIFIED_STATUS_NOT_ACCEPTED
          mark_not_accepted
        when TimelineEvent::VERIFIED_STATUS_PENDING
          mark_pending
        else
          raise 'Unexpected status specified!'
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
        post_on_facebook if @timeline_event.share_on_facebook
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
      end
    end

    def mark_pending
      TimelineEvent.transaction do
        @timeline_event.revert_to_pending!
      end
    end

    def update_karma_points
      return unless @points.present? || points_for_target.present?
      add_karma_points
    end

    def previous_points_for_target
      return 0 if @target.blank?
      founder = @timeline_event.founder
      previous_target_timeline_events = @target.founder_role? ? @target.timeline_events.where(founder: founder) : @target.timeline_events.where(startup: founder.startup)
      KarmaPoint.where(source: previous_target_timeline_events).sum(:points)
    end

    def points_for_new_status
      if @points.present?
        @points
      else
        applicable_points > previous_points_for_target ? applicable_points - previous_points_for_target : 0
      end
    end

    def add_karma_points
      points = points_for_new_status
      return if points.zero?

      KarmaPoint.create!(
        source: @timeline_event,
        founder: founder,
        startup: @timeline_event.startup,
        activity_type: "Added a new Timeline event - #{@timeline_event.title}",
        points: points
      )
    end

    def founder
      @timeline_event.founder_event? ? @timeline_event.founder : nil
    end

    def applicable_points
      return 0 unless @new_status.in?([TimelineEvent::VERIFIED_STATUS_VERIFIED, TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT]) && points_for_target.present?

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
      @points_for_target ||= begin
        @target&.points_earnable || 0
      end
    end

    def post_on_facebook
      TimelineEvents::FacebookPostJob.perform_later(@timeline_event)
    end
  end
end
