class CreateCoachNoteMutator < ApplicationQuery
  include AuthorizeCoach

  property :note, validates: { presence: true }
  property :student_id, validates: { presence: true }
  property :author_id, validates: { presence: true }

  def create_note
    CoachNote.transaction do
      CoachNote.create!(note: note, author_id: author_id, student_id: student_id)
    end
  end
end
