class SchoolPolicy < ApplicationPolicy
  def show?
    return false if user.blank?

    # record should belong to current school
    return false unless record.school == current_school

    user.school_admin.present?
  end

  alias customize? show?
  alias images? show?
  alias admins? show?
end
