class CreateAnswerMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :description, validates: { length: { minimum: 1, maximum: 15_000, message: 'InvalidLengthDescription' } }
  property :question_id, validates: { presence: { message: 'BlankQuestionId' } }

  def create_answer
    answer = Answers::CreateService.new(current_user, question, description).create
    answer.id
  end

  private

  alias authorized? authorized_create?

  def community
    @community ||= question&.community
  end

  def question
    @question ||= Question.find_by(id: question_id)
  end
end
