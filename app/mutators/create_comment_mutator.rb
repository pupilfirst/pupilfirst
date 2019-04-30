class CreateCommentMutator < ApplicationMutator
  include ActiveSupport::Concern

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
    comment.id
  end

  def authorize
    # Can't comment at PupilFirst.
    raise UnauthorizedMutationException if current_school.blank?

    # Only a student or coach can comment.
    raise UnauthorizedMutationException if current_founder.blank? && current_coach.blank?

    # Can only comment on commentables in the same school.
    raise UnauthorizedMutationException if commentable&.school != current_school
  end

  private

  def commentable
    @commentable ||= case commentable_type
      when Comment::COMMENTABLE_TYPE_QUESTION
        Question.find_by(id: commentable_id)
      when Comment::COMMENTABLE_TYPE_ANSWER
        Answer.find_by(id: commentable_id)
    end
  end
end
