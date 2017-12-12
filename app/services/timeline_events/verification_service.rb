module TimelineEvents
  class VerificationService
    def initialize(timeline_event, notify: true)
      @timeline_event = timeline_event
      @notify = notify
      @target = @timeline_event.target
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def update_status(status, grade: nil, skill_grades: nil, points: nil)
      raise UnexpectedGradeException unless grade.blank? || grade.in?(TimelineEvent.valid_grades)

      @grade = grade
      @skill_grades = skill_grades
      @points = points
      @timeline_event.update!(grade: @grade)
      @new_status = status

      case @new_status
        when TimelineEvent::STATUS_VERIFIED
          mark_verified
        when TimelineEvent::STATUS_NEEDS_IMPROVEMENT
          mark_needs_improvement
        when TimelineEvent::STATUS_NOT_ACCEPTED
          mark_not_accepted
        when TimelineEvent::STATUS_PENDING
          mark_pending
        else
          raise UnexpectedStatusException
      end

      TimelineEvents::VerificationNotificationJob.perform_later(@timeline_event) if @notify

      [@timeline_event, points_for_new_status]
    end

    # rubocop:enable Metrics/CyclomaticComplexity

    private

    def mark_verified
      TimelineEvent.transaction do
        @timeline_event.verify!
        update_grade_and_score
        update_karma_points
        update_timeline_updated_on
        reset_startup_level if @timeline_event.timeline_event_type.end_iteration?
        update_founder_resume if @timeline_event.timeline_event_type.resume_submission?
      end

      post_on_facebook if @timeline_event.share_on_facebook
    end

    def mark_needs_improvement
      TimelineEvent.transaction do
        @timeline_event.update!(status: TimelineEvent::STATUS_NEEDS_IMPROVEMENT, status_updated_at: Time.zone.now)
        update_timeline_updated_on
        reset_startup_level if @timeline_event.timeline_event_type.end_iteration?
      end
    end

    def mark_not_accepted
      TimelineEvent.transaction do
        @timeline_event.update!(status: TimelineEvent::STATUS_NOT_ACCEPTED, status_updated_at: Time.zone.now)
        cancel_reset_request if @timeline_event.timeline_event_type.end_iteration?
      end
    end

    def mark_pending
      TimelineEvent.transaction do
        @timeline_event.update!(status: TimelineEvent::STATUS_PENDING, status_updated_at: Time.zone.now)
      end
    end

    def update_karma_points
      return unless @points.present? || points_for_target.present?
      add_karma_points
    end

    def add_karma_points
      points = points_for_new_status
      return if points.zero?

      KarmaPoints::CreateService.new(@timeline_event, points).execute
    end

    def points_for_new_status
      if @points.present?
        @points
      else
        points_for_target
      end
    end

    def founder
      @timeline_event.founder_event? ? @timeline_event.founder : nil
    end

    def grade_multiplier(grade)
      {
        TimelineEvent::GRADE_GOOD => 1,
        TimelineEvent::GRADE_GREAT => 1.5,
        TimelineEvent::GRADE_WOW => 2
      }.with_indifferent_access[grade]
    end

    def points_for_target
      @points_for_target ||= begin
        if @skill_grades.present?
          total_karma_points
        elsif @grade.present?
          @target.points_earnable * grade_multiplier(@grade) || 0
        end
      end
    end

    def post_on_facebook
      TimelineEvents::FacebookPostJob.perform_later(@timeline_event)
    end

    def startup
      @startup ||= @timeline_event.startup
    end

    def reset_startup_level
      return if startup.requested_restart_level.blank?
      Startups::RestartService.new(startup.team_lead).restart(startup.requested_restart_level)
    end

    def cancel_reset_request
      Startups::RestartService.new(startup.team_lead).cancel
    end

    def update_timeline_updated_on
      return if @timeline_event.founder_event?

      startup.update!(timeline_updated_on: @timeline_event.event_on)
    end

    def update_founder_resume
      if @timeline_event.timeline_event_files.present?
        update_resume_file
      elsif @timeline_event.links.present?
        update_resume_link
      else
        raise AttachmentMissingException
      end
    end

    def update_resume_file
      resume_file = @timeline_event.timeline_event_files.first
      if resume_file.private?
        raise AttachmentPrivacyException
      else
        founder.update!(resume_file: resume_file, resume_url: nil)
      end
    end

    def update_resume_link
      resume_link = @timeline_event.links.first
      if resume_link['private']
        raise AttachmentPrivacyException
      else
        founder.update!(resume_url: resume_link['url'], resume_file: nil)
      end
    end

    def update_grade_and_score
      if @skill_grades.present?
        @timeline_event.update!(score: computed_score)
        # The overall grade for the timeline event will be the one that corresponds to the lower rounded off score.
        @timeline_event.update!(grade: grade_to_score.key(computed_score.floor))
      elsif @grade.present?
        @timeline_event.update!(grade: @grade, score: grade_to_score[@grade].to_f)
      end
    end

    def computed_score
      pc_count = @skill_grades.count.to_f
      total_points = 0

      @skill_grades.values.each do |grade|
        total_points += grade_to_score[grade]
      end

      score = (total_points / pc_count)
      # Round the score to the lower 0.5
      (score * 2).floor / 2.0
    end

    def grade_to_score
      { 'good' => 1, 'great' => 2, 'wow' => 3 }
    end

    def total_karma_points
      target_skills = TargetSkill.where(target: @target)
      total_karma_points = 0
      @total_karma_points = @skill_grades.each do |skill_id, grade|
        total_karma_points += target_skills.find_by(skill_id: skill_id.to_i).base_karma_points * grade_multiplier(grade)
      end
      total_karma_points.round
    end
  end
end
