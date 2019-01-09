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

  def show?(timeline_event)
    return false if timeline_event.blank?

    if timeline_event.founder_event?
      # Show founder events only to the founder who posted it.
      timeline_event.founders.present? && timeline_event.founders.first == current_founder
    else
      # Show verified events to everyone, and non-verified events to startup founders.
      return true if timeline_event.passed_at.present?

      timeline_event.founders.in?(current_founder)
    end
  end

  def review?
    coach = user.faculty

    return false if coach.blank?

    coach.startups.where(id: record.startup).exists? || coach.courses.where(id: record.startup.level.course).exists?
  end

  def undo_review?
    review?
  end

  def send_feedback?
    review?
  end
end
