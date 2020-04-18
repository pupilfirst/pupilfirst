class FacultyPolicy < ApplicationPolicy
  def index?
    scope.exists?
  end

  def show?
    record.about.present?
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def connect?
    # Cannot connect if connect link is blank.
    return false if record.connect_link.blank?

    if current_founder.present?
      course = current_founder.startup.course
      # It should be possible to connect to course-enrolled coaches if the course connect feature is enabled in course.
      return true if course.can_connect? && course.faculty.where(id: record.id).exists?
    end

    # Coaches and admins can view all connect links.
    return true if current_coach.present? || current_school_admin.present?

    false
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  class Scope < Scope
    def resolve
      # Pupilfirst doesn't have coaches.
      return scope.none if current_school.blank?

      current_school.faculty.where(public: true)
    end
  end
end
