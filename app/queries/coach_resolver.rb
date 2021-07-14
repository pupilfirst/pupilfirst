class CoachResolver < ApplicationQuery
  property :coach_id

  def coach
    current_school.faculty.find_by(id: coach_id)
  end

  private

  def authorized?
    return true if coach_id.blank?

    return false if current_user&.faculty.blank?

    coach&.school == current_school
  end
end
