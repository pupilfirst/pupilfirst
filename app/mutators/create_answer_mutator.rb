class CreateAnswerMutator < ApplicationMutator
  include ActiveSupport::Concern

  attr_accessor :description
  attr_accessor :question_id

  validates :description, length: { minimum: 1, message: 'InvalidLengthValue' }, allow_nil: false
  validates :question_id, presence: { message: 'BlankCommentableId' }

  def create_answer
    answer = Answer.create!(
      user: current_user,
      description: description,
      question: question
    )
    answer.id
  end

  def authorize
    # Can't answer at PupilFirst.
    raise UnauthorizedMutationException if current_school.blank?

    # Only a student or coach can answer.
    raise UnauthorizedMutationException if current_founder.blank? && current_coach.blank?

    # Can only answer questions in the same school.
    raise UnauthorizedMutationException if question&.school != current_school
  end

  private

  def question
    @question ||= Question.find_by(id: question_id)
  end
end
