class CommunityPolicy < ApplicationPolicy
  def show?
    return false if scope.blank?

    scope.where(id: record.id).exists?
  end

  alias new_topic? show?

  class Scope < Scope
    def resolve
      # Pupilfirst doesn't have community.
      return scope.none if current_school.blank?

      # School admin and Coach has access to all communities in a school.
      return scope.where(school: current_school) if current_school_admin.present? || current_coach.present?

      course_ids = user.founders.not_dropped_out.joins(:course).select(:course_id)
      scope.where(school: current_school).joins(:courses).where(courses: { id: course_ids }).distinct
    end
  end
end
