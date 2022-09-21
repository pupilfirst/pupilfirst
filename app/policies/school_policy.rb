class SchoolPolicy < ApplicationPolicy
  def school_router?
    return false if user.blank?

    user.school_admin.present?
  end

  alias customize? school_router?
  alias images? school_router?
  alias admins? school_router?
end
