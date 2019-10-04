class TimelineEventPolicy < ApplicationPolicy
  def show?
    return false if record.blank?

    return false if record.evaluation_criteria.blank?

    CoursePolicy.new(@pundit_user, record.target.course).review?
  end

  def review?
    return false if current_coach.blank?

    current_coach.startups.where(id: record.startup).exists? || current_coach.courses.where(id: record.startup.level.course).exists?
  end

  def undo_review?
    review?
  end

  def send_feedback?
    review?
  end
end
