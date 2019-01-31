class ApplicationPolicy
  attr_reader :user, :record, :current_founder, :current_school

  def initialize(user, record)
    @pundit_user = user
    @user = user.current_user
    @record = record
    @current_founder = user.current_founder
    @current_school = user.current_school
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(@pundit_user, record.class)
  end

  class Scope
    attr_reader :user, :scope, :current_founder, :current_school

    def initialize(user, scope)
      @user = user.current_user
      @scope = scope
      @current_founder = user.current_founder
      @current_school = user.current_school
    end

    def resolve
      scope
    end
  end
end
