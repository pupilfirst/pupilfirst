class ArchiveCommunityResourceMutator < ApplicationMutator
  attr_accessor :id
  attr_accessor :resource_type

  validates :id, presence: true
  validates :resource_type, inclusion: { in: %w[Question Answer Comment] }

  def archive
    community_resource.update!(archived: true, archiver: current_user)
  end

  def authorized?
    # Can't archive at PupilFirst, current user must exist, Can only archive only in the same school.
    return false unless current_school.present? && current_user.present? && (school == current_school)

    # Faculty can archive resources
    return true if current_coach.present?

    community_resource&.editor == current_user
  end

  private

  def community_resource
    @community_resource ||=
      if resource_type == "Question"
        Question.find_by(id: id)
      elsif resource_type == "Answer"
        Answer.find_by(id: id)
      elsif resource_type == "Comment"
        Comment.find_by(id: id)
      end
  end

  def school
    return community_resource&.school if resource_type.in? %w[question answer]

    if resource_type == "Comment"
      if community_resource&.commentable_type == "Question"
        Question.find_by(id: community_resource.commentable_id)&.school
      elsif community_resource&.commentable_type == "Answer"
        Answer.find_by(id: community_resource.commentable_id)&.school
      end
    end
  end
end
