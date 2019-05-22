class CreateCommentMutator < ApplicationMutator
  attr_accessor :value
  attr_accessor :commentable_type
  attr_accessor :commentable_id

  validates :commentable_type, inclusion: { in: Comment::VALID_COMMENTABLE_TYPES, message: 'InvalidCommentableType' }
  validates :value, length: { minimum: 1, message: 'InvalidLengthValue' }, allow_nil: false
  validates :commentable_id, presence: { message: 'BlankCommentableId' }

  def create_comment
    comment = Comment.create!(
      user: current_user,
      commentable: commentable,
      value: value
    )
    update_last_activity_for_question if commentable_type == Comment::COMMENTABLE_TYPE_QUESTION
    comment.id
  end

  def authorized?
    # Can't comment at PupilFirst, current user must exist, Can only comment in the same school.
    return false unless current_school.present? && current_user.present? && (commentable&.school == current_school)

    # Coach has access to all communities
    return true if current_coach.present?

    # User should have access to the community
    current_user.founders.includes(:course).where(courses: { id: commentable.community.courses }).any?
  end

  private

  def update_last_activity_for_question
    # rubocop:disable Rails/SkipsModelValidations
    @commentable.touch(:last_activity_at)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def commentable
    @commentable ||= case commentable_type
      when Comment::COMMENTABLE_TYPE_QUESTION
        Question.find_by(id: commentable_id)
      when Comment::COMMENTABLE_TYPE_ANSWER
        Answer.find_by(id: commentable_id)
    end
  end
end
