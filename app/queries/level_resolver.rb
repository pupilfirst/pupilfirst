class LevelResolver < ApplicationQuery
  include AuthorizeCoach

  property :level_id
  property :course_id

  def level
    @level ||= course.levels.find_by(id: level_id)
  end

  private

  def authorized?
    level_id.present? ? super : true
  end

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
