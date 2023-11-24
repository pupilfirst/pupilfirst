module Organisations
  class CohortPolicy < ApplicationPolicy
    def show?
      return true if user.school_admin.present?

      organisation_ids = user.admins_organisations.pluck(:id)

      return false if organisation_ids.blank?

      # Only give access to the current org_admin if org_admin's organisation has students enrolled in the said course.
      record
        .students
        .joins(user: [:organisations_users])
        .exists?(organisations_users: { organisation_id: organisation_ids })
    end

    alias students? show?
  end
end
