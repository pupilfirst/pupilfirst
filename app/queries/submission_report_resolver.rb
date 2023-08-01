class SubmissionReportResolver < ApplicationQuery
  property :id

  def submission_report
    @submission_report ||= SubmissionReport.find_by(id: id)
  end

  def authorized?
    return false if submission_report.blank?

    return false if current_user.faculty.blank?

    current_user.faculty.cohorts.exists?(
      id: submission_report.submission.students.first.cohort
    )
  end
end
