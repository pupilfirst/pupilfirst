class CohortPolicy < ApplicationPolicy
  def show?
    return false if record.ended?

    organisation_ids = user.organisations.pluck(:id)

    return if organisation_ids.blank?

    record
      .founders
      .joins(:user)
      .exists?(users: { organisation_id: organisation_ids })
  end

  alias students? show?
end
