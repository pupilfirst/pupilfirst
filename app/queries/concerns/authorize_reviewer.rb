module AuthorizeReviewer
  include ActiveSupport::Concern

  def authorized?
    return true if current_user.school_admin.present?

    return false if faculty.blank?

    faculty.reviewable_courses.where(id: course).exists?
  end

  def faculty
    @faculty ||= current_user.faculty
  end

  def course
    @course ||= current_school.courses.find(course_id)
  end
end
