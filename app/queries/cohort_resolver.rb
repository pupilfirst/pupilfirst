class CohortResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id

  def cohort
    @cohort ||= current_school.cohorts.find_by(id: id)
  end

  private

  def resource_school
    cohort&.school
  end
end
