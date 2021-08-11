class LevelsResolver < ApplicationQuery
  include AuthorizeCoach

  property :course_id

  delegate :levels, to: :course

  private

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
