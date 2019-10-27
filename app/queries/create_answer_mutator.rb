class CreateAnswerMutator < ApplicationQuery
  include AuthorizeCommunityUser

  attr_accessor :description
  attr_accessor :question_id

  validates :description, length: { minimum: 1, maximum: 15_000, message: 'InvalidLengthDescription' }
  validates :question_id, presence: { message: 'BlankQuestionId' }

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
