class ArchiveCommunityResourceMutator < ApplicationMutator
  attr_accessor :id
  attr_accessor :resource_type

  validates :resource_type, inclusion: { in: [Question, Answer, Comment].map(&:to_s) }

  def archive
    community_resource.update!(archived: true, archiver: current_user)
  end

  def authorized?
    return false if community_resource.blank?

    # Can't archive at PupilFirst, current user must exist, Can only archive only in the same school.
    return false unless current_school.present? && current_user.present? && (resource_school == current_school)

    # Faculty can archive resources
    return true if current_coach.present?

    community_resource.creator == current_user
  end

  private

  def community_resource
    @community_resource ||= case resource_type
      when "Question"
        Question.find_by(id: id)
      when "Answer"
        Answer.find_by(id: id)
      when "Comment"
        Comment.find_by(id: id)
      else
        raise "Unexpected resource type #{resource_type}"
    end
  end

  def resource_school
    return community_resource.school if resource_type.in?([Question.name, Answer.name])

    community_resource.commentable.school if resource_type == Comment.name
  end
end
