class QuestionPolicy < ApplicationPolicy
  def show?
    CommunityPolicy.new(@pundit_user, record.community).show?
  end
end
