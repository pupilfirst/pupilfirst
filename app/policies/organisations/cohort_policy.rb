module Organisations
  class CohortPolicy < ApplicationPolicy
    def show?
      return true if user.school_admin.present?

      organisation_ids = user.organisations.pluck(:id)

      return false if organisation_ids.blank?

      record
        .students
        .joins(:user)
        .exists?(users: { organisation_id: organisation_ids })
    end

    alias students? show?
  end
end
