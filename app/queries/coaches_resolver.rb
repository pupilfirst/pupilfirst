class CoachesResolver < ApplicationQuery
  include AuthorizeCoach

  property :coach_ids
  property :course_id

  def coaches
    if coach_ids.nil?
      course.faculty.distinct
    else
      course.faculty.distinct.where(id: coach_ids)
    end
  end

  private

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
