class CreateCoachNoteMutator < ApplicationQuery
  include AuthorizeCoach

  property :note, validates: { presence: true, length: { minimum: 1, maximum: 10_000, message: 'InvalidLengthCoachNote' } }
  property :student_id, validates: { presence: true }

  def create_note
    CoachNote.transaction do
      CoachNote.create!(note: note, author_id: author_id, student_id: student_id)
    end
  end

  private

  def course
    Founder.find(student_id).course
  end

  def author_id
    current_user.faculty.id
  end
end
