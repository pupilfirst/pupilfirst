class StandingsResolver < ApplicationQuery
  def standings
    @standings ||= current_school.standings.where(archived_at: nil)
  end

  def authorized?
    current_school && current_school_admin.present?
  end
end
