class CreateCoachNoteMutator < ApplicationQuery
  include AuthorizeCoach

  property :note, validates: { presence: true }
  property :student_id, validates: { presence: true }

  def create_note
    CoachNote.transaction do
      CoachNote.create!(note: note, author_id: author_id, student_id: student_id)
    end
  end

  def author_id
    current_user.faculty.id
  end
end
