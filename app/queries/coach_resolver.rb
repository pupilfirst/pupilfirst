class CoachResolver < ApplicationQuery
  include AuthorizeCoach

  property :coach_id
  property :course_id

  def coach
    course.faculty.find_by(id: coach_id)
  end

  private

  def authorized?
    coach_id.present? ? super : true
  end

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
