module Schools
  class ResourcePolicy < ApplicationPolicy
    def create?
      # Is this user allowed to create a Resource
      # CoursePolicy.new(user, record.target.course).update?
      true
    end

    alias update? create?

    def destroy?
      true
    end
  end
end
