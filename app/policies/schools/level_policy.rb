module Schools
  class LevelPolicy < ApplicationPolicy
    def create?
      CoursePolicy.new(@pundit_user, record.course).curriculum?
    end

    alias update? create?
  end
end
