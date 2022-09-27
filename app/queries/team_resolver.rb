class TeamResolver < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :id

  def team
    @team ||= Team.find_by(id: id)
  end

  private

  def resource_school
    team&.school
  end
end
