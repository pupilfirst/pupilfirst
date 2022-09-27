class CourseResolver < ApplicationQuery
  property :id

  def course
    @course ||= current_school.courses.find_by(id: id)
  end

  private

  def authorized?
    current_school_admin.present?
  end
end
