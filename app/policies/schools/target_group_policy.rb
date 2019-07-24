module Schools
  class TargetGroupPolicy < ApplicationPolicy
    def create?
      CurriculaPolicy.new(@pundit_user, record.course).show? && !record.course.ended?
    end

    alias update? create?

    def destroy?
      true
    end
  end
end
