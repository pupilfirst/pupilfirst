class CreateAnswerLikeMutator < ApplicationMutator
  include AuthorizeCommunityUser

  attr_accessor :answer_id

  validates :answer_id, presence: { message: 'BlankAnswerId' }
  validate :like_should_not_exist

  def like_should_not_exist
    return if answer.answer_likes.where(user: current_user).empty?

    errors[:base] << 'LikeExists'
  end

  def create_answer_like
    AnswerLike.create!(
      user: current_user,
      answer: answer
    ).id
  end

  private

  alias authorized? authorized_create?

  def community
    @community ||= answer&.community
  end

  def answer
    @answer ||= Answer.find_by(id: answer_id)
  end
end
