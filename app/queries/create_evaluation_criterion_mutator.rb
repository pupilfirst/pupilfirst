class CreateEvaluationCriterionMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :name, validates: { presence: true, length: { minimum: 2, maximum: 50 } }
  property :description, validates: { presence: true, length: { minimum: 2, maximum: 150 } }
  property :max_grade, validates: { presence: true }
  property :pass_grade, validates: { presence: true }
  property :grades_and_labels, validates: { presence: true }
  property :course_id, validates: { presence: true }

  def correct_grades_and_labels
    return if @course.max_grade == (grade_labels.values - [""]).count

    raise "CreateEvaluationCriterionMutator received invalid grades and labels #{grades_and_labels}"
  end

  def create_evaluation_criterion
    EvaluationCriterion.transaction do
      ec = EvaluationCriterion.create!(
        name: name, description: description,
        course: course,
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
      [grades_and_label[:grade].to_s, grades_and_label[:label].strip]
    end.to_h
  end

  def course
    Course.find(course_id)
  end
end
