module Schools
  class AssignmentPolicy < ApplicationPolicy
    def update?
      user&.school_admin.present? && user.school == current_school
    end
  end
end
