class FacultyPolicy < ApplicationPolicy
  def index?
    scope.exists?
  end

  def show?
    record.about.present?
  end

  def connect?
    # Cannot connect if user doesn't have a student profile.
    return false if current_founder.blank?

    # Cannot connect if connect link is blank or doesn't have appropriate slots available.
    return false unless record.connect_slots.available_for_founder.exists? || record.connect_link.present?

    # It should be possible to connect to course-enrolled coaches.
    return true if record.courses.where(id: current_founder.startup.course).exists?

    # It should be possible to connect to coaches enrolled directly to current team.
    return true if record.startups.where(id: current_founder.startup).exists?

    false
  end

  class Scope < Scope
    def resolve
      # Pupilfirst doesn't have coaches.
      return scope.none if current_school.blank?

      scope.where(school: current_school, public: true)
    end
  end
end
