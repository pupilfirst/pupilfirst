class FounderPolicy < ApplicationPolicy
  def founder_profile?
    record&.startup.present? && !record.level_zero?
  end

  def timeline_event_show?(timeline_event)
    return false if timeline_event.blank?

    if timeline_event.founder_event?
      # Show founder events only to the founder who posted it.
      timeline_event.founder.present? && timeline_event.founder == current_founder
    else
      # Show verified events to everyone, and non-verified events to startup founders.
      return true if timeline_event.verified_or_needs_improvement?

      timeline_event.founder == current_founder
    end
  end

  def edit?
    founder_profile? && record.subscription_active?
  end

  def update?
    edit?
  end

  def fee?
    record&.startup.present? && record.startup.payments.pending.any?
  end

  def fee_submit?
    fee?
  end

  def select?
    record.present? && user.founders.count > 1
  end
end
