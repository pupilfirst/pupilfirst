class TargetInfoResolver < ApplicationQuery
  include AuthorizeViewSubmissions

  property :target_id
  property :course_id

  def target_info
    @target_info ||= course.targets.find_by(id: target_id)
  end

  private

  def authorized?
    target_id.present? ? super : true
  end

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
