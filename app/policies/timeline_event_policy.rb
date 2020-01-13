class TimelineEventPolicy < ApplicationPolicy
  def show?
    return false if record.blank?

    return false if record.evaluation_criteria.blank?

    CoursePolicy.new(@pundit_user, record.target.course).review?
  end
end
