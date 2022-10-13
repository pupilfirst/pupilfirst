module QueryAuthorizeCoach
  include ActiveSupport::Concern

  def query_authorized?
    # Needs a valid faculty profile
    return false if current_user&.faculty.blank?

    return false if course&.school != current_school

    current_user.faculty.cohorts.exists?(id: submission.founders.first.cohort)
  end
end
