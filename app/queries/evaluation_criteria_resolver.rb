class EvaluationCriteriaResolver < ApplicationQuery
  property :course_id

  delegate :evaluation_criteria, to: :course

  private

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end

  def authorized?
    course.present? && current_school_admin.present?
  end
end
