class HasArchivedCoachNotesResolver < ApplicationQuery
  property :student_id

  def has_archived_coach_notes # rubocop:disable Naming/PredicateName
    CoachNote.archived.exists?(student_id: student.id)
  end

  private

  def authorized?
    return false if current_user.blank?

    current_user.faculty.courses.exists?(id: student&.course)
  end

  def student
    @student ||= Founder.find_by(id: student_id)
  end
end
