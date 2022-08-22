class ApplicantResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :applicant_id

  def applicant
    @applicant ||= Applicant.find_by(id: applicant_id)
  end

  def allow_token_auth?
    true
  end

  private

  def resource_school
    applicant&.course&.school
  end
end
