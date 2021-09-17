class CoachesResolver < ApplicationQuery
  include AuthorizeCoach

  property :coach_ids
  property :course_id

  def coaches
    coach_ids.present? ? course.faculty.where(id: coach_ids) : course.faculty
  end

  private

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
