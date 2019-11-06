class DestroyAnswerLikeMutator < ApplicationQuery
  property :id, validates: { presence: true }

  def destroy_answer_like
    answer_like.destroy!
  end

  def authorized?
    # Can't unlike at PupilFirst, current user must exist, Can only unlike on answers in the same school.
    return false unless current_school.present? && current_user.present? && (answer_like&.answer&.school == current_school)

    # Only a the liked user can can unlike.
    answer_like&.user == current_user
  end

  private

  def answer_like
    @answer_like ||= AnswerLike.find_by(id: id)
  end
end
