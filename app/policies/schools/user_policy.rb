module Schools
  class UserPolicy < ApplicationPolicy
    def index?
      user&.school_admin.present? && user.school == current_school
    end

    def show?
      current_school_admin.present? && record.school == user.school
    end

    alias update? show?

    class Scope < Scope
      def resolve
        if user&.school_admin.present? && user.school == current_school
          scope.where(school: current_school)
        else
          scope.none
        end
      end
    end
  end
end
