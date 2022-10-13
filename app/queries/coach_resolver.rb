class CoachResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id

  def coach
    @coach ||= current_school.faculty.find_by(id: id)
  end

  private

  def resource_school
    coach&.school
  end
end
