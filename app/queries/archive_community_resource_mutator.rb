class ArchiveCommunityResourceMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :id
  property :resource_type, validates: { inclusion: { in: [Question, Answer, Comment].map(&:to_s) } }

  def archive
    community_resource.update!(archived: true, archiver: current_user)
  end

  private

  def community_resource
    @community_resource ||= case resource_type
      when Question.name
        Question.find_by(id: id)
      when Answer.name
        Answer.find_by(id: id)
      when Comment.name
        Comment.find_by(id: id)
      else
        raise "Unexpected resource type #{resource_type}"
    end
  end

  def community
    @community ||= case resource_type
      when Question.name, Answer.name
        community_resource.community
      when Comment.name
        community_resource.commentable.community
    end
  end

  def creator
    community_resource.creator
  end

  alias authorized? authorized_update?
end
