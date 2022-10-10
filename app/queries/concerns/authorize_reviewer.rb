module AuthorizeReviewer
  include ActiveSupport::Concern

  def authorized?
    return false if course&.school != current_school

    return false if coach.blank?

    coach.cohorts.exists?(id: submission.founders.first.cohort_id)
  end

  def coach
    @coach ||= current_user.faculty
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end
end
