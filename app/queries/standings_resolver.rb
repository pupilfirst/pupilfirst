class StandingsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :school_id

  def standings
    @standings ||= school.standings.where(archived_at: nil)
  end

  def resource_school
    school
  end

  def school
    @school ||= School.find_by(id: school_id)
  end
end
