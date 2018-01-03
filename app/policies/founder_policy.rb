class FounderPolicy < ApplicationPolicy
  def founder_profile?
    record&.startup.present? && !record.level_zero?
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
    # fee?

    # Temporarily disable fee payments.
    false
  end
end
