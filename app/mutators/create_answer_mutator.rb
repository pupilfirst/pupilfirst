class CreateAnswerMutator < ApplicationMutator
  attr_accessor :description
  attr_accessor :question_id

  validates :description, length: { minimum: 1, maximum: 5000, message: 'InvalidLengthDescription' }
  validates :question_id, presence: { message: 'BlankQuestionId' }

  def create_answer
    answer = Answer.transaction do
      question.update!(last_activity_at: Time.zone.now)

      Answer.create!(
        creator: current_user,
        question: question,
        description: description
      )
    end

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
