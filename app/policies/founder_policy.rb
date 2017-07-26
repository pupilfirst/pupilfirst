class FounderPolicy < ApplicationPolicy
  def founder_profile?
    record.startup.present? && !record.level_zero?
  end

  def edit?
    founder_profile? && record.subscription_active?
  end

  def update?
    edit?
  end

  def fee?
    founder_profile? && record.payments.pending.any?
  end

  def fee_submit?
    fee?
  end
end
