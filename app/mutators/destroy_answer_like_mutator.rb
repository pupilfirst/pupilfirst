class DestroyAnswerLikeMutator < ApplicationMutator
  include ActiveSupport::Concern

  attr_accessor :id

  validates :id, presence: true

  def destroy_answer_like
    answer_like.destroy!
  end

  def authorized?
    # Can't unlike at PupilFirst.
    raise UnauthorizedMutationException if current_school.blank?

    # Only a student or coach can unlike.
    raise UnauthorizedMutationException if current_founder.blank? && current_coach.blank?

    # Can only unlike on answers in the same school.
    raise UnauthorizedMutationException if answer_like&.answer&.school != current_school

    # Only a the liked user can can unlike.
    raise UnauthorizedMutationException if answer_like&.user != current_user

    true
  end

  private

  def answer_like
    @answer_like ||= AnswerLike.find_by(id: id)
  end
end
