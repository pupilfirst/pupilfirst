class TimelineEventPolicy < ApplicationPolicy
  def show?
    return false if record.blank?

    user.faculty.courses.where(id: record.target.course.id).present?
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
