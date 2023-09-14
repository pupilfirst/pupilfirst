class ReviewedTargetsInfoResolver < ApplicationQuery
  include AuthorizeViewSubmissions

  property :course_id

  def reviewed_targets_info
    course.targets.live.joins(:evaluation_criteria).distinct
  end

  private

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
