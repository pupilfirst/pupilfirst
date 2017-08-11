class TimelineEventPolicy < ApplicationPolicy
  def create?
    # User must be a founder with a startup.
    return false if user&.founder&.startup.blank?

    # The startup must be Level 1+.
    return false if user.founder.startup.level_zero?

    true
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
end
