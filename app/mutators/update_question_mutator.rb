class UpdateQuestionMutator < ApplicationMutator
  attr_accessor :id
  attr_accessor :title
  attr_accessor :description

  validates :title, length: { minimum: 1, maximum: 250, message: 'InvalidLengthTitle' }, allow_nil: false
  validates :description, length: { minimum: 1, message: 'InvalidLengthDescription' }, allow_nil: false

  def update_question
    question.text_versions.create!(value: question.description, user: question.creator, edited_at: question.updated_at)
    question.update!(title: title, description: description, editor: current_user)
  end

  def authorized?
    # Can't edit question at PupilFirst, current user must exist, Can only edit question in the same school.
    return false unless current_school.present? && current_user.present? && (question&.school == current_school)

    # Faculty can edit questions
    return true if current_coach.present?

    question&.creator == current_user
  end

  private

  def question
    @question ||= Question.find_by(id: id)
  end
end
