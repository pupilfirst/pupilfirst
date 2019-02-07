class TimelineEventPolicy < ApplicationPolicy
  def create?
    # Current course must not have ended.
    return false if current_founder.startup.course.ended?

    true
  end

  def destroy?
    # User who cannot create, cannot destroy.
    return false unless create?

    # Do not allow destruction of passed timeline events, or one.
    return false if record.passed_at?

    # Do not allow destruction of timeline events with startup feedback.
    return false if record.startup_feedback.present?

    true
  end

  def show?
    return false if record.blank?

    # Public can see only passed team submissions.
    if record.passed? && record.team_event?
      return true
    end

    # Other submissions can be seen only by team members.
    record.founders.where(id: current_founder).present?
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
