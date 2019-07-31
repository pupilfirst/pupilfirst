module Schools
  class LevelPolicy < ApplicationPolicy
    def create?
      CoursePolicy.new(@pundit_user, record.course).curriculum? && !record.course.ended?
    end

    alias update? create?
  end
end
