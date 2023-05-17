class SubmissionDetailsResolver < ApplicationQuery
  property :submission_id

  def submission_details
    {
      all_submissions: submissions_from_same_set_of_students,
      submission: submission,
      target_id: target.id,
      target_title: target.title,
      students: students_data,
      level_number: level.number,
      level_id: level.id,
      team_name: team_name,
      submission_reports: submission.submission_reports,
      target_evaluation_criteria_ids: target.evaluation_criteria.pluck(:id),
      evaluation_criteria: evaluation_criteria,
      review_checklist: review_checklist,
      inactive_students: inactive_students,
      coaches: coaches,
      course_id: level.course_id,
      created_at: submission.created_at,
      preview: preview?,
      reviewer_details: reviewer_details,
      submission_report_poll_time:
        Rails.application.secrets.submission_report_poll_time,
      inactive_submission_review_allowed_days:
        Rails.application.secrets.inactive_submission_review_allowed_days
    }
  end

  delegate :review_checklist, to: :target

  def submission
    @submission ||= TimelineEvent.find_by(id: submission_id)
  end

  def reviewer_details
    return submission if submission.reviewer_id.present?
  end

  def coaches
    FacultyFounderEnrollment
      .where(founder_id: student_ids)
      .includes(faculty: [user: [avatar_attachment: :blob]])
      .map { |c| c.faculty }
  end

  def submissions_from_same_set_of_students
    submissions
      .includes(:startup_feedback)
      .order("timeline_events.created_at DESC")
      .select do |s|
        s.timeline_event_owners.pluck(:founder_id).sort == student_ids
      end
  end

  def submissions
    TimelineEvent
      .where(target_id: submission.target_id)
      .joins(:timeline_event_owners)
      .where(timeline_event_owners: { founder_id: student_ids })
      .distinct
  end

  def student_ids
    @student_ids ||= submission.founders.pluck(:id).sort
  end

  def target
    @target ||= submission.target
  end

  def evaluation_criteria_fields
    %w[name id max_grade pass_grade grade_labels]
  end

  def evaluation_criteria
    # EvaluationCriterion of target OR EvaluationCriteria of submissions
    target_criteria =
      target.evaluation_criteria.as_json(only: evaluation_criteria_fields)

    submission_criteria =
      EvaluationCriterion
        .joins(timeline_event_grades: :timeline_event)
        .where(timeline_events: { id: submissions_from_same_set_of_students })
        .distinct
        .as_json(only: evaluation_criteria_fields)

    (target_criteria + submission_criteria).uniq
  end

  def level
    @level ||= target.level
  end

  def students
    @students ||= submission.founders.includes(:user)
  end

  def students_data
    students.map { |student| { id: student.id, name: student.name } }
  end

  def authorized?
    return false if submission.blank?

    return false if current_user.faculty.blank?

    current_user.faculty.cohorts.exists?(
      id: submission.founders.first.cohort_id
    )
  end

  def inactive_students
    submission.founders.count != submission.founders.active.count
  end

  def preview?
    submission.founders.active.empty?
  end

  def students_have_same_team
    Founder.where(id: student_ids).distinct(:team_id).pluck(:team_id).one?
  end

  def team_name
    if submission.team_submission? && students_have_same_team &&
         !student_ids.one?
      Founder.find_by(id: student_ids.first).team.name
    end
  end
end
