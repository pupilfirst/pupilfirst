class AnswerPolicy < ApplicationPolicy
  def versions?
    QuestionPolicy.new(@pundit_user, record.question).show?
  end
end
