class ApplicantPolicy < ApplicationPolicy
  def enroll?
    true
  end
end
