class CreateEvaluationCriterionMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :name, validates: { presence: true, length: { minimum: 2, maximum: 50 } }
  property :max_grade, validates: { presence: true }
  property :pass_grade, validates: { presence: true }
  property :grades_and_labels, validates: { presence: true }
  property :course_id, validates: { presence: true }

  validate :unique_name_and_grade_params

  def unique_name_and_grade_params
    return if course.evaluation_criteria.find_by(name: name, max_grade: max_grade, pass_grade: pass_grade).blank?

    errors[:base] << "Criterion already exists with same name, max grade and pass grade"
  end

  def create_evaluation_criterion
    EvaluationCriterion.transaction do
      ec = EvaluationCriterion.create!(
        name: name,
        course_id: course_id,
        max_grade: max_grade,
        pass_grade: pass_grade,
        grade_labels: grade_labels
      )
      ec
    end
  end

  private

  def grade_labels
    grades_and_labels.map do |grades_and_label|
      grade = grades_and_label[:grade]
      label = grades_and_label[:label].strip
      [grade.to_s, label.presence || grade.humanize]
    end.to_h
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end
end
