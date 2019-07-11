class CreateCommentMutator < ApplicationMutator
  include AuthorizeCommunityUser

  attr_accessor :value
  attr_accessor :commentable_type
  attr_accessor :commentable_id

  validates :commentable_type, inclusion: { in: [Answer.name, Question.name], message: 'InvalidCommentableType' }
  validates :value, length: { minimum: 1, message: 'InvalidLengthValue' }, allow_nil: false
  validates :commentable_id, presence: { message: 'BlankCommentableId' }

  def create_comment
    comment = Comments::CreateService.new(current_user, commentable, value)
    comment.id
  end

  private

  alias authorized? authorized_create?

  def community
    commentable.community
  end

  def commentable
    @commentable ||= case commentable_type
      when Question.name
        Question.find_by(id: commentable_id)
      when Answer.name
        Answer.find_by(id: commentable_id)
      else
        raise "Invalid commentable_type #{commentable_type}"
    end
  end
end
