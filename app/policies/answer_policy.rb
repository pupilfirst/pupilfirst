class AnswerPolicy < ApplicationPolicy
  def show?
    QuestionPolicy.new(@pundit_user, record.question).show?
  end

  def edit?
    show?
    record.user == user
  end

  alias new? show?

  alias create? show?

  alias update? edit?

  alias destroy? edit?
end
