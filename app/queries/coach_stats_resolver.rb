class CoachStatsResolver < ApplicationQuery
  property :coach_id
  property :course_id

  def coach_stats
    {
      reviewed_submissions: reviewed_submissions,
      pending_submissions: pending_submissions
    }
  end

  def reviewed_submissions
    TimelineEvent
      .joins(:course)
      .where(courses: { id: course.id })
      .where(evaluator_id: coach.id)
      .count
  end

  def pending_submissions
    TimelineEvent
      .pending_review
      .joins(:students)
      .where(students: { id: assigned_student_ids })
      .distinct
      .count
  end

  def assigned_student_ids
    @assigned_student_ids ||=
      coach.students.joins(:course).where(courses: { id: course.id }).pluck(:id)
  end

  def authorized?
    current_user.school_admin.present? && course.present? && coach.present?
  end

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end

  def coach
    @coach ||= course.faculty.find_by(id: coach_id)
  end
end
