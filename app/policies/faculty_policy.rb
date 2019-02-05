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

    # Cannot connect if the coach doesn't have appropriate slots available.
    return false unless record.connect_slots.available_for_founder.exists?

    # Can connect only if coach been assigned to review the student's team.
    record.reviewable_startups(current_founder.course).where(id: current_founder.startup).exists?
  end

  class Scope < Scope
    def resolve
      # Pupilfirst doesn't have coaches.
      return scope.none if current_school.blank?

      scope.where(school: current_school)
    end
  end
end
