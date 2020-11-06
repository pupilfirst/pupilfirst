module AuthorizeReviewer
  include ActiveSupport::Concern

  def authorized?
    return false if course&.school != current_school

    return true if current_user.school_admin.present?

    return false if faculty.blank?

    faculty.courses.exists?(id: course_id)
  end

  def faculty
    @faculty ||= current_user.faculty
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end
end
