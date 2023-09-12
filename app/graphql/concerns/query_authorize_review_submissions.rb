module QueryAuthorizeReviewSubmissions
  include ActiveSupport::Concern

  def query_authorized?
    return false if course&.school != current_school

    return false if current_user&.faculty.blank?

    current_user.faculty.cohorts.exists?(id: submission.students.first.cohort)
  end
end
