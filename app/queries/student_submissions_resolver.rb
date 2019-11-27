class StudentSubmissionsResolver < ApplicationQuery
  property :student_id

  def student_submissions
    student.timeline_events.evaluated_by_faculty.includes(target: :level).order("created_at DESC")
  end

  def authorized?
    return false if student.blank?

    return false if current_user.faculty.blank?

    current_user.faculty.reviewable_courses.where(id: student.course).exists?
  end

  def student
    @student ||= Founder.find_by(id: student_id)
  end
end
