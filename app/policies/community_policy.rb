class CommunityPolicy < ApplicationPolicy
  def show?
    return false if scope.blank?

    scope.exists?(id: record.id)
  end

  alias new_topic? show?

  class Scope < Scope
    def resolve
      # School admin and Coach has access to all communities in a school.
      if current_school_admin.present? ||
           (current_coach.present? && !current_coach.exited?)
        return scope.where(school: current_school)
      end

      course_ids =
        user.students.not_dropped_out.joins(:course).select(:course_id)
      scope
        .where(school: current_school)
        .joins(:courses)
        .where(courses: { id: course_ids, archived_at: nil })
        .distinct
    end
  end
end
