class QuestionPolicy < ApplicationPolicy
  def show?
    CommunityPolicy.new(@pundit_user, record.community).show?
  end

  def edit?
    show?
    record.user == user
  end

  alias new? show?

  alias create? show?

  alias update? edit?
end
