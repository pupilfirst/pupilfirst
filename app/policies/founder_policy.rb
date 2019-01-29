class FounderPolicy < ApplicationPolicy
  def founder_profile?
    record&.startup.present?
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
    record.present? && user.founders.where(id: record).present?
  end
end
