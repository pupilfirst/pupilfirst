class PostPolicy < ApplicationPolicy
  def versions?
    CommunityPolicy.new(@pundit_user, record.topic.community).show?
  end
end
