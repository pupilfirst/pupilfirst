module Schools
  class AssignmentPolicy < ApplicationPolicy
    def update_milestone?
      (user&.school_admin.present? && user.school == current_school) ||
        user.course_authors.where(course: record.course).present?
    end
  end
end
