class CreateAnswerMutator < ApplicationMutator
  attr_accessor :description
  attr_accessor :question_id

  validates :description, length: { minimum: 1, message: 'InvalidLengthValue' }, allow_nil: false
  validates :question_id, presence: { message: 'BlankCommentableId' }

  def create_answer
    answer = Answer.create!(
      creator: current_user,
      question: question,
      description: description
    )
    # rubocop:disable Rails/SkipsModelValidations
    question.touch(:last_activity_at)
    # rubocop:enable Rails/SkipsModelValidations
    answer.id
  end

  def authorized?
    # Can't answer at PupilFirst, current user must exist, Can only answer questions in the same school.
    return false unless current_school.present? && current_user.present? && (question&.school == current_school)

    # Coach has access to all communities
    return true if current_coach.present?

    # User should have access to the community
    current_user.founders.includes(:course).where(courses: { id: question.community.courses }).any?
  end

  private

  def question
    @question ||= Question.find_by(id: question_id)
  end
end
