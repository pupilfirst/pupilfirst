module Organisations
  class CoursePolicy < ApplicationPolicy
    def active_cohorts?
      return true if user.school_admin.present?

      organisation_ids = user.admins_organisations.pluck(:id)

      return false if organisation_ids.blank?

      # Only give access to the current org_admin if org_admins organisation has students enrolled in the said course.
      record
        .students
        .joins(user: [:organisations_users])
        .exists?(organisations_users: { organisation_id: organisation_ids })
    end

    alias ended_cohorts? active_cohorts?
  end
end
