module Schools
  class CohortPolicy < ApplicationPolicy
    def bulk_import_students?
      user&.school_admin.present? && user.school == current_school
    end

    class Scope < Scope
      def resolve
        current_school.cohorts
      end
    end
  end
end
