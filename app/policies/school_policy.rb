class SchoolPolicy < ApplicationPolicy
  def show?
    return false if user.blank?

    user.school_admin.present?
  end

  alias configuration? show?
  alias customize? show?
  alias images? show?
  alias admins? show?
end
