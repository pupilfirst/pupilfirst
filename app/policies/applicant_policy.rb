class ApplicantPolicy < ApplicationPolicy
  def enroll?
    record.course.in? current_school.courses.where(enable_public_signup: true)
  end
end
