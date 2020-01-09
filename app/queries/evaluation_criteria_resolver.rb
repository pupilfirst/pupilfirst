class EvaluationCriteriaResolver < ApplicationQuery
  property :course_id

  delegate :evaluation_criteria, to: :course

  private

  def course
    @course ||= current_school.courses.find(course_id)
  end

  def authorized?
    current_school_admin.present?
  end
end
