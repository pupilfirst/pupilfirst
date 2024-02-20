class StandingsResolver < ApplicationQuery
  def standings
    @standings ||= current_school.standings.live
  end

  def authorized?
    current_school && current_school_admin.present?
  end
end
