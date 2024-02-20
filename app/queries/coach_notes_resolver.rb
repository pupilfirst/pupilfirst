class CoachNotesResolver < ApplicationQuery
  property :student_id

  def coach_notes
    student.coach_notes.not_archived.order("created_at DESC").limit(20)
  end

  def authorized?
    return false if student&.school != current_school

    return true if current_school_admin.present?

    current_user.faculty.cohorts.exists?(id: student&.cohort_id)
  end

  def student
    @student ||= Student.find_by(id: student_id)
  end
end
