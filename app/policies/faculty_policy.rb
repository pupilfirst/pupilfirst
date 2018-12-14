class FacultyPolicy < ApplicationPolicy
  def connect?
    current_founder&.subscription_active? && record.connect_slots.available_for_founder.exists?
  end
end
