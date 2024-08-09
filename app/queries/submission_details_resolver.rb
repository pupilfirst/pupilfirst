class SubmissionDetailsResolver < ApplicationQuery
  property :submission_id

  def submission_details
    {
      all_submissions: submissions_of_owners_with_feedback,
      submission: submission,
      target_id: target.id,
      target_title: target.title,
      students: students_data,
      team_name: team_name,
      submission_reports: submission.submission_reports,
      target_evaluation_criteria_ids: target.evaluation_criteria.pluck(:id),
      evaluation_criteria: unique_criteria_from_target_and_submissions,
      review_checklist: review_checklist,
      coaches: personal_coaches_assigned_to_the_submission_owners,
      course_id: target.course.id,
      created_at: submission.created_at,
      reviewer_details: reviewer_details,
      submission_report_poll_time:
        Settings.submission_report_poll_time,
      reviewable: can_the_submission_be_reviewed?,
      warning: submission_review_warning
    }
  end

  delegate :review_checklist, to: :target

  def allowed_days_for_reviewing_an_inactive_submission
    Settings.inactive_submission_review_allowed_days
  end

  def submission_has_inactive_owners?
    submission.students.count != submission.students.active.count
  end

  def submission_is_within_review_allowed_period?
    days_elapsed_since_submission =
      (Time.zone.now - submission.created_at) / 1.day
    days_elapsed_since_submission <
      allowed_days_for_reviewing_an_inactive_submission
  end

  def can_the_submission_be_reviewed?
    return false unless user_is_a_coach_assigned_to_cohort?

    !submission_has_inactive_owners? ||
      submission_is_within_review_allowed_period?
  end

  def submission_review_warning
    unless user_is_a_coach_assigned_to_cohort?
      # The only user who can see this warning is a school admin.
      return(
        I18n.t("queries.submission_details_resolver.only_coaches_can_review")
      )
    end

    generate_warning_when_a_submission_has_inactive_owners
  end

  def generate_warning_when_a_submission_has_inactive_owners
    # This message shown when submission has inactive owners.
    if submission_has_inactive_owners?
      submission_can_be_reviewed_until =
        submission.created_at +
          allowed_days_for_reviewing_an_inactive_submission.days

      key_suffix =
        if submission_is_within_review_allowed_period?
          "with_timestamp"
        else
          "without_timestamp"
        end

      return(
        I18n.t(
          "queries.submission_details_resolver.student_dropped_out_message_#{key_suffix}",
          count: students.count,
          timestamp:
            submission_can_be_reviewed_until.strftime("%d %B, %Y, %H:%M %:z")
        )
      )
    end
  end

  def submission
    @submission ||= TimelineEvent.find_by(id: submission_id)
  end

  def reviewer_details
    return submission if submission.reviewer_id.present?
  end

  def personal_coaches_assigned_to_the_submission_owners
    FacultyStudentEnrollment
      .where(student_id: student_ids)
      .includes(faculty: [user: [avatar_attachment: :blob]])
      .map { |c| c.faculty }
  end

  def submissions_of_owners_with_feedback
    unique_submissions_by_target_and_owners
      .includes(:startup_feedback)
      .order("timeline_events.created_at DESC")
      .select do |s|
        s.timeline_event_owners.pluck(:student_id).sort == student_ids
      end
  end

  def unique_submissions_by_target_and_owners
    TimelineEvent
      .where(target_id: submission.target_id)
      .joins(:timeline_event_owners)
      .where(timeline_event_owners: { student_id: student_ids })
      .distinct
  end

  def student_ids
    @student_ids ||= submission.students.pluck(:id).sort
  end

  def target
    @target ||= submission.target
  end

  def evaluation_criteria_fields
    %w[name id max_grade grade_labels]
  end

  def unique_criteria_from_target_and_submissions
    # EvaluationCriterion of target OR EvaluationCriteria of submissions
    target_criteria =
      target.evaluation_criteria.as_json(only: evaluation_criteria_fields)

    submission_criteria =
      EvaluationCriterion
        .joins(timeline_event_grades: :timeline_event)
        .where(timeline_events: { id: unique_submissions_by_target_and_owners })
        .distinct
        .as_json(only: evaluation_criteria_fields)

    (target_criteria + submission_criteria).uniq
  end

  def students
    @students ||= submission.students.includes(:user)
  end

  def students_data
    students.map { |student| { id: student.id, name: student.name } }
  end

  def authorized?
    return false if target&.course&.school != current_school

    return true if current_school_admin.present?

    user_is_a_coach_assigned_to_cohort?
  end

  def user_is_a_coach_assigned_to_cohort?
    if instance_variable_defined?(:@user_is_a_coach_assigned_to_cohort)
      return @user_is_a_coach_assigned_to_cohort
    end

    @user_is_a_coach_assigned_to_cohort =
      current_user&.faculty&.cohorts&.exists?(
        id: submission.students.first.cohort_id
      )
  end

  def submission_owners_are_from_same_team?
    Student.where(id: student_ids).distinct(:team_id).pluck(:team_id).one?
  end

  def team_name
    if submission.team_submission? && submission_owners_are_from_same_team? &&
         !student_ids.one?
      Student.find_by(id: student_ids.first).team.name
    end
  end
end
