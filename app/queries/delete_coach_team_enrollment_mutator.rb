class DeleteCoachTeamEnrollmentMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :coach_id, validates: { presence: true }
  property :team_id, validates: { presence: true }

  def delete_coach_team_enrollment
    coach_team_enrollment.destroy!
  end

  validate :coach_team_enrollment_must_exist

  private

  def resource_school
    coach_team_enrollment&.startup&.school
  end

  def coach_team_enrollment_must_exist
    return if coach_team_enrollment.present?

    errors[:base] << 'Team assignment for the coach does not exist'
  end

  def coach_team_enrollment
    @coach_team_enrollment ||= FacultyStartupEnrollment.find_by(startup_id: team_id, faculty_id: coach_id)
  end
end
