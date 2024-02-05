class SchoolPolicy < ApplicationPolicy
  def show?
    return false if user.blank?

    user.school_admin.present?
  end

  alias customize? show?
  alias images? show?
  alias admins? show?
  alias school_router? show?
  alias standing? show?
  alias toggle_standing? show?
  alias code_of_conduct? show?
  alias update_code_of_conduct? show?
end
