class CoachNotesResolver < ApplicationQuery
  property :student_id

  def coach_notes
    student.coach_notes.not_archived.order('created_at DESC').limit(20)
  end

  def authorized?
    return false if current_user.blank?

    current_user.faculty.courses.exists?(id: student&.course)
  end

  def student
    @student ||= Founder.find_by(id: student_id)
  end
end
