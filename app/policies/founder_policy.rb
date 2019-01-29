class FounderPolicy < ApplicationPolicy
  def founder_profile?
    record&.startup.present?
  end

  def edit?
    founder_profile?
  end

  def update?
    edit?
  end

  def select?
    record.present? && user.founders.where(id: record).present?
  end
end
