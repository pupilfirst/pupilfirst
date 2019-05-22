class CreateAnswerLikeMutator < ApplicationMutator
  attr_accessor :answer_id

  validates :answer_id, presence: { message: 'BlankAnswerId' }
  validate :like_from_user_does_not_exist

  def like_from_user_does_not_exist
    return if answer.answer_likes.where(user: current_user).blank?

    raise 'LikeExist'
  end

  def create_answer_like
    like = AnswerLike.create!(
      user: current_user,
      answer: answer
    )
    like.id
  end

  def authorized?
    # Can't like at PupilFirst, current user must exist, Can only like answers in the same school.
    return false unless current_school.present? && current_user.present? && (answer&.school == current_school)

    # Coach has access to all communities
    return true if current_coach.present?

    # User should have access to the community
    current_user.founders.includes(:course).where(courses: { id: answer.community.courses }).any?
  end

  private

  def answer
    @answer ||= Answer.find_by(id: answer_id)
  end
end
