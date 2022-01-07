class CourseResolver < ApplicationQuery
  property :id

  def allow_token_auth?
    true
  end

  def course
    if id.present?
      @course ||= current_school.courses.find_by(id: id)
    end
  end

  private

  def authorized?
    current_school_admin.present?
  end
end
