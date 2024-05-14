class StudentDetailsResolver < ApplicationQuery
  property :student_id

  def student_details
    {
      email: student.email,
      assignments_completed: assignments_completed,
      assignments_pending_review: assignments_pending_review,
      total_assignments: current_course_targets_with_assignments.distinct.count,
      total_page_reads: total_page_reads,
      total_targets: current_course_targets.count,
      evaluation_criteria: evaluation_criteria,
      quiz_scores: quiz_scores,
      average_grades: average_grades,
      team: team,
      student: student,
      milestones_completion_status: milestones_completion_status,
      can_modify_coach_notes: user_is_a_coach_for_the_student?
    }
  end

  def user_is_a_coach_for_the_student?
    current_user&.faculty&.cohorts&.exists?(id: student&.cohort_id) || false
  end

  def average_grades
    @average_grades ||=
      TimelineEventGrade
        .where(timeline_event: submissions_for_grades)
        .group(:evaluation_criterion_id)
        .average(:grade)
        .map do |ec_id, average_grade|
          {
            evaluation_criterion_id: ec_id,
            average_grade: average_grade.round(1)
          }
        end
  end

  def assignments_completed
    latest_submissions.passed.distinct(:target_id).count(:target_id)
  end

  def assignments_pending_review
    latest_submissions.pending_review.distinct(:target_id).count(:target_id)
  end

  def current_course_targets_with_assignments
    current_course_targets.joins(:assignments).where(
      assignments: {
        archived: false
      }
    )
  end

  def total_page_reads
    student.page_reads.where(target: current_course_targets).count
  end

  def current_course_targets
    course.targets.live
  end

  def quiz_scores
    latest_submissions.where.not(quiz_score: nil).pluck(:quiz_score)
  end

  def course
    @course ||= student.course
  end

  def authorized?
    return false if student&.school != current_school

    return false if current_user.blank?

    return true if current_user.id == student.user_id

    return true if current_school_admin.present?

    current_user.faculty&.cohorts&.exists?(id: student.cohort_id)
  end

  def student
    @student ||= Student.includes(:user).find_by(id: student_id)
  end

  def team
    @team ||= student.team
  end

  def latest_submissions
    @latest_submissions ||=
      student
        .latest_submissions
        .joins(:target)
        .where(targets: { id: current_course_targets_with_assignments })
  end

  def submissions_for_grades
    latest_submissions
      .includes(:students, target: :assignments)
      .select do |submission|
        submission.target.individual_target? ||
          (submission.student_ids.sort == student.team_student_ids)
      end
  end

  def evaluation_criteria
    EvaluationCriterion
      .where(id: average_grades.pluck(:evaluation_criterion_id))
      .map { |ec| { id: ec.id, name: ec.name, max_grade: ec.max_grade } }
  end

  def milestones_completion_status
    targets_with_milestone = current_course_targets.milestone
    passed_target_ids =
      student
        .latest_submissions
        .where(target: targets_with_milestone)
        .passed
        .pluck(:target_id)

    targets_with_milestone.map do |target|
      {
        id: target.id,
        title: target.title,
        completed: passed_target_ids.include?(target.id),
        milestone_number: target.assignments.first.milestone_number
      }
    end
  end
end
