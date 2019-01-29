class FacultyPolicy < ApplicationPolicy
  def connect?
    current_founder.present? && record.connect_slots.available_for_founder.exists?
  end
end
