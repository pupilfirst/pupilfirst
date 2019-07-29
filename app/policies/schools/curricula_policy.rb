module Schools
  class CurriculaPolicy < ApplicationPolicy
    def show?
      # All school admins can view the curricula
      return true if user.school_admin.present?

      # All course authors can view the curricula
      return true if user.course_authors.where(course: record).present?
    end
  end
end
