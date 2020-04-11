class DeleteCoachTeamEnrollmentMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :coach_id, validates: { presence: true }
  property :team_id, validates: { presence: true }

  def delete_coach_team_enrollment
    coach_team_enrollment.destroy!
  end

  validate :coach_team_enrollment_must_exist

  private

  def coach_team_enrollment_must_exist
    return if coach_team_enrollment.present?

    errors[:base] << 'Team assignment for the coach does not exist'
  end

  def coach
    current_school.faculty.find_by(id: coach_id)
  end

  def team
    current_school.startups.find_by(id: team_id)
  end

  def coach_team_enrollment
    FacultyStartupEnrollment.find_by(startup: team, faculty: coach)
  end
end
