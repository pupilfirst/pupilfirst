class TimelineEventPolicy < ApplicationPolicy
  def create?
    # User must be a founder with a startup.
    user&.founder&.startup.present?
  end

  def destroy?
    # User who cannot create, cannot destroy.
    return false unless create?

    # Do not allow destruction of verified / needs improvement timeline events, or one.
    return false if record.verified_or_needs_improvement?

    # Do not allow destruction of timeline events with startup feedback.
    return false if record.startup_feedback.present?

    true
  end

  def review?
    coach = user.faculty
    coach.present? && record.startup.in?(coach.startups)
  end

  def undo_review?
    review?
  end
end
