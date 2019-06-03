class AnswerPolicy < ApplicationPolicy
  def versions?
    CommunityPolicy.new(@pundit_user, record.question.community).show?
  end
end
