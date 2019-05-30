class UpdateAnswerMutator < ApplicationMutator
  attr_accessor :id
  attr_accessor :description

  validates :description, length: { minimum: 1, message: 'InvalidLengthDescription' }, allow_nil: false

  def update_answer
    answer.text_versions.create!(value: answer.description, user: answer.creator, edited_at: answer.updated_at)
    answer.update!(description: description, editor: current_user)
  end

  def authorized?
    # Can't edit answers at PupilFirst, current user must exist, Can only edit answers in the same school.
    return false unless current_school.present? && current_user.present? && (answer&.school == current_school)

    # Faculty can edit answers
    return true if current_coach.present?

    question&.creator == current_user
  end

  private

  def answer
    @answer ||= Answer.find_by(id: id)
  end
end
