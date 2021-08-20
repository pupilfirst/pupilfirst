class TeamCoachesResolver < ApplicationQuery
  include AuthorizeCoach

  property :course_id

  def team_coaches
    course
      .faculty
      .joins(startups: :course)
      .where(startups: { courses: { id: course.id } })
      .includes(user: { avatar_attachment: :blob })
      .distinct
  end

  private

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
