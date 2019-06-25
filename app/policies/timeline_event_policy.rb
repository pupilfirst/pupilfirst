class TimelineEventPolicy < ApplicationPolicy
  def create?
    # Current course must not have ended.
    return false if current_founder.startup.course.ended? || !current_founder.startup.active?

    true
  end

  def show?
    return false if record.blank?

    # Public can see only passed team submissions.
    if record.passed? && record.team_event?
      return true
    end

    # Other submissions can be seen only by team members.
    record.founders.where(user_id: user&.id).present?
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
