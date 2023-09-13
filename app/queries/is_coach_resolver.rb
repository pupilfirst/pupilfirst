class IsCoachResolver < ApplicationQuery
  property :student_id

  def is_coach # rubocop:disable Naming/PredicateName
    current_user&.faculty&.cohorts&.exists?(id: student&.cohort_id) || false
  end

  private

  def authorized?
    return false if student&.school != current_school

    return true if current_school_admin.present?

    return false if current_user.blank?

    current_user&.faculty&.cohorts&.exists?(id: student&.cohort_id)
  end

  def student
    @student ||= Student.find_by(id: student_id)
  end
end
