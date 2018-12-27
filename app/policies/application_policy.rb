class ApplicationPolicy
  attr_reader :user, :record, :current_founder, :current_school

  def initialize(user, record)
    @user = user
    @record = record
    @current_founder = user&.current_founder
    @current_school = user&.current_school
  end

  def index?
    false
  end

  def show?
    false
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

  class Scope
    attr_reader :user, :scope, :current_founder, :current_school

    def initialize(user, scope)
      @user = user
      @scope = scope
      @current_founder = user&.current_founder
      @current_school = user&.current_school
    end

    def resolve
      scope.all
    end
  end
end
