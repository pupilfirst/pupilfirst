class StudentSubmissionsResolver < ApplicationQuery
  property :student_id

  def student_submissions
    student.timeline_events.evaluated_by_faculty.includes(target: :level).order("created_at DESC")
  end

  def authorized?
    return false if student.blank?

    return false if coach.blank?

    coach.courses.where(id: student.course.id).exists? || coach.startups.where(id: student.startup_id).present?
  end

  def student
    @student ||= Founder.find_by(id: student_id)
  end

  def coach
    @coach ||= current_user.faculty
  end
end
