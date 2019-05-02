class CreateAnswerLikeMutator < ApplicationMutator
  include ActiveSupport::Concern

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

  def authorize
    # Can't comment at PupilFirst.
    raise UnauthorizedMutationException if current_school.blank?

    # Only a student or coach can like an answer.
    raise UnauthorizedMutationException if current_founder.blank? && current_coach.blank?

    # Can only like on answers in the same school.
    raise UnauthorizedMutationException if answer&.school != current_school
  end

  private

  def answer
    @answer ||= Answer.find_by(id: answer_id)
  end
end
