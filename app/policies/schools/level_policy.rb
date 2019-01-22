module Schools
  class LevelPolicy < ApplicationPolicy
    def create?
      # All school admins can create new level.
      CoursePolicy.new(user, record.course).update?
    end

    alias update? create?

    def destroy?
      true
    end
  end
end
