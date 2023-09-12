class HasArchivedCoachNotesResolver < ApplicationQuery
  property :student_id

  def has_archived_coach_notes # rubocop:disable Naming/PredicateName
    CoachNote.archived.exists?(student_id: student.id)
  end

  private

  def authorized?
    return false if student&.school != current_school

    return true if current_school_admin.present?

    return false if current_user.blank?

    current_user.faculty.cohorts.exists?(id: student&.cohort_id)
  end

  def student
    @student ||= Student.find_by(id: student_id)
  end
end
