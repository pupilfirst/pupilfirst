class SubmissionReportResolver < ApplicationQuery
  include AuthorizeCoach

  property :id

  def submission_report
    @submission_report ||= SubmissionReport.find_by(id: id)
  end

  def authorized?
    return false if submission_report.blank?

    return false if current_user.faculty.blank?

    current_user.faculty.courses.exists?(
      id: submission_report.submission.target.course
    )
  end
end
