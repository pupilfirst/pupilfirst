class CourseCoachesResolver < ApplicationQuery
  include AuthorizeCoach

  property :course_id

  def course_coaches
    course.faculty.includes(user: { avatar_attachment: :blob }).distinct
  end

  private

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
