module Organisations
  class CoursePolicy < ApplicationPolicy
    def ongoing_cohorts?
      return true if user.school_admin.present?

      organisation_ids = user.organisations.pluck(:id)

      return false if organisation_ids.blank?

      record
        .founders
        .joins(:user)
        .exists?(users: { organisation_id: organisation_ids })
    end

    alias ended_cohorts? ongoing_cohorts?
  end
end
