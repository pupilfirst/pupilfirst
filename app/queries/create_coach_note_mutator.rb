class CreateCoachNoteMutator < ApplicationQuery
  property :note, validates: { presence: true, length: { minimum: 1, maximum: 10_000, message: 'InvalidLengthCoachNote' } }
  property :student_id, validates: { presence: true }

  def create_note
    CoachNote.transaction do
      CoachNote.create!(note: note, author_id: current_user.id, student_id: student_id)
    end
  end

  private

  def authorized?
    coach.present? && coach.courses.exists?(id: course.id)
  end

  def course
    student&.course
  end

  def student
    @student ||= Founder.find_by(id: student_id)
  end

  def coach
    @coach ||= current_user.faculty
  end
end
