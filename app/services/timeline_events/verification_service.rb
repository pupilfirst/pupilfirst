module TimelineEvents
  class VerificationService
    def initialize(timeline_event, notify: true)
      @timeline_event = timeline_event
      @notify = notify
      @target = @timeline_event.target
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def update_status(status, grade: nil, skill_grades: nil, points: nil)
      if status == TimelineEvent::STATUS_VERIFIED && @target&.key.blank?
        raise 'Only one of grade, skill_grades, points should be present' unless [grade, skill_grades, points].one?
        raise 'Not a valid grade' if grade.present? && !grade.in?(TimelineEvent.valid_grades)
      end

      @grade = grade
      @skill_grades = skill_grades
      @points = points
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

    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    private

    def mark_verified
      TimelineEvent.transaction do
        @timeline_event.verify!
        update_grade_and_score
        update_karma_points
        update_timeline_updated_on
        update_founder_resume if @timeline_event.timeline_event_type.resume_submission?
        update_admission_stage if @timeline_event.target.in?(targets_for_admissions)
      end

      post_on_facebook if @timeline_event.share_on_facebook
    end

    def mark_needs_improvement
      TimelineEvent.transaction do
        @timeline_event.update!(status: TimelineEvent::STATUS_NEEDS_IMPROVEMENT, status_updated_at: Time.zone.now)
        update_timeline_updated_on
      end
    end

    def mark_not_accepted
      TimelineEvent.transaction do
        @timeline_event.update!(status: TimelineEvent::STATUS_NOT_ACCEPTED, status_updated_at: Time.zone.now)
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
        elsif @grade.present? && @target.points_earnable.present?
          @target.points_earnable * grade_multiplier(@grade)
        else
          0
        end
      end
    end

    def post_on_facebook
      TimelineEvents::FacebookPostJob.perform_later(@timeline_event)
    end

    def startup
      @startup ||= @timeline_event.startup
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
        store_skill_grades
      elsif @grade.present?
        @timeline_event.update!(score: grade_to_score(@grade).to_f)
      end
    end

    def computed_score
      pc_count = @skill_grades.count.to_f

      total_points = @skill_grades.values.sum do |grade|
        grade_to_score(grade)
      end

      score = (total_points / pc_count)
      # Round the score to the lower 0.5
      (score * 2).floor / 2.0
    end

    def grade_to_score(grade)
      case grade
        when TimelineEvent::GRADE_GOOD
          1
        when TimelineEvent::GRADE_GREAT
          2
        when TimelineEvent::GRADE_WOW
          3
        else
          raise 'Not a valid grade'
      end
    end

    def total_karma_points
      TargetSkill.where(target: @target, skill_id: @skill_grades.keys).sum do |target_skill|
        grade = @skill_grades[target_skill.skill_id.to_s]
        target_skill.base_karma_points * grade_multiplier(grade)
      end.round
    end

    def store_skill_grades
      @skill_grades.each do |skill_id, grade|
        karma_points = TargetSkill.find_by(target: @target, skill_id: skill_id.to_i).base_karma_points.to_f * grade_multiplier(grade)
        TimelineEventGrade.create!(timeline_event: @timeline_event, skill_id: skill_id, grade: grade, karma_points: karma_points.round)
      end
    end

    def update_admission_stage
      new_stage = { Target::KEY_R1_TASK => Startup::ADMISSION_STAGE_R1_TASK_PASSED,
                    Target::KEY_R1_SHOW_PREVIOUS_WORK => Startup::ADMISSION_STAGE_R1_TASK_PASSED,
                    Target::KEY_R2_TASK => Startup::ADMISSION_STAGE_R2_TASK_PASSED,
                    Target::KEY_ATTEND_INTERVIEW => Startup::ADMISSION_STAGE_INTERVIEW_PASSED }[@timeline_event.target.key]

      Admissions::UpdateStageService.new(@timeline_event.startup, new_stage).execute

      Intercom::LevelZeroStageUpdateJob.perform_later(@timeline_event.startup.team_lead, new_stage)
    end

    def targets_for_admissions
      Target.live.where(key: [Target::KEY_R1_TASK, Target::KEY_R1_SHOW_PREVIOUS_WORK, Target::KEY_R2_TASK, Target::KEY_ATTEND_INTERVIEW])
    end
  end
end
