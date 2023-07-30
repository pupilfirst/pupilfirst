module QueryAuthorizeReviewSubmissions
  include ActiveSupport::Concern

  def query_authorized?
    return false if current_user&.faculty.blank?

    return false if course&.school != current_school

    current_school_admin.present? ||
      current_user.faculty.cohorts.exists?(id: submission.students.first.cohort)
  end
end
