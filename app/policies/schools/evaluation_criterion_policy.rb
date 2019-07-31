module Schools
  class EvaluationCriterionPolicy < ApplicationPolicy
    def create?
      # All school admins can create new criteria.
      user&.school_admin.present?
    end

    alias update? create?

    def destroy?
      # TODO: Account for criterion-target assignments
      true
    end
  end
end
