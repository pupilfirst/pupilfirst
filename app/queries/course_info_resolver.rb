class CourseInfoResolver < ApplicationQuery
  property :courseId

  def allow_token_auth?
    true
  end

  def course_info
    if courseId.present?
      @course ||= current_school.courses.find_by(id: courseId)
    end

  end
  private

  def authorized?
    current_school_admin.present?
  end



end
