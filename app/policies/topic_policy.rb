class TopicPolicy < ApplicationPolicy
  def show?
    CommunityPolicy.new(@pundit_user, record.community).show?
  end

  alias versions? show?
end
