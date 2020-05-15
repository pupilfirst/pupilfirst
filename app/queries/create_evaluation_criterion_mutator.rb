class CreateEvaluationCriterionMutator < ApplicationQuery
  include AuthorizeAuthor

  property :name, validates: { presence: true, length: { minimum: 2, maximum: 50 } }
  property :max_grade, validates: { presence: true }
  property :pass_grade, validates: { presence: true }
  property :grades_and_labels, validates: { presence: true }
  property :course_id, validates: { presence: true }

  validate :unique_name_and_grade_params
  validate :course_must_be_present

  def unique_name_and_grade_params
    return if course.blank?

    return if course.evaluation_criteria.find_by(name: name, max_grade: max_grade, pass_grade: pass_grade).blank?

    errors[:base] << 'Criterion already exists with same name, max grade and pass grade'
  end

  def course_must_be_present
    return if course.present?

    errors[:base] << "Course with ID #{course_id} does not exist"
  end

  def create_evaluation_criterion
    EvaluationCriterion.transaction do
      EvaluationCriterion.create!(
        name: name,
        course_id: course_id,
        max_grade: max_grade,
        pass_grade: pass_grade,
        grade_labels: grade_labels,
      )
    end
  end

  private

  def resource_school
    course&.school
  end

  def grade_labels
    grades_and_labels.map do |grades_and_label|
      grade = grades_and_label[:grade]
      label = grades_and_label[:label].strip
      label = label.present? ? label[0..40] : grade.humanize.capitalize
      { grade: grade, label: label }
    end
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end
end
