class CoachesResolver < ApplicationQuery
  include AuthorizeViewSubmissions

  property :coach_ids
  property :course_id

  def coaches
    scope =
      coach_ids.nil? ? course.faculty : course.faculty.where(id: coach_ids)
    scope.includes(:user)
  end

  private

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
