class UserProfilePolicy < ApplicationPolicy
  def edit?
    record&.school_id == current_school.id && record.user == user
  end

  def update?
    edit?
  end
end
