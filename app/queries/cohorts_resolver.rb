class CohortsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id

  delegate :cohorts, to: :course

  private

  def resource_school
    course&.school
  end

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
