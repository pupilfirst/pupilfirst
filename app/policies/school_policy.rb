class SchoolPolicy < ApplicationPolicy
  def show?
    return false if user.blank?

    user.school_admins.where(school: record).present?
  end
end
