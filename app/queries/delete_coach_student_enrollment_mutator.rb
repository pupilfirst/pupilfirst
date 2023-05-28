class DeleteCoachStudentEnrollmentMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :coach_id, validates: { presence: true }
  property :student_id, validates: { presence: true }

  def delete_coach_student_enrollment
    coach_student_enrollment.destroy!
  end

  validate :coach_student_enrollment_must_exist

  private

  def resource_school
    coach_student_enrollment&.student&.school
  end

  def coach_student_enrollment_must_exist
    return if coach_student_enrollment.present?

    errors.add(:base, 'Student assignment for the coach does not exist')
  end

  def coach_student_enrollment
    @coach_student_enrollment ||=
      FacultyStudentEnrollment.find_by(
        student_id: student_id,
        faculty_id: coach_id
      )
  end
end
