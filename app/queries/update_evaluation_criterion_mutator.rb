class UpdateEvaluationCriterionMutator < ApplicationQuery
  include AuthorizeAuthor

  property :id
  property :name, validates: { presence: true, length: { minimum: 1, maximum: 50 } }
  property :grades_and_labels, validates: { presence: true }

  validate :evaluation_criterion_must_be_present

  def evaluation_criterion_must_be_present
    return if evaluation_criterion.present?

    errors[:base] << "Could not find evaluation criterion with ID #{id}"
  end

  def update_evaluation_criterion
    evaluation_criterion.update!(
      name: name,
      grade_labels: grade_labels,
    )

    evaluation_criterion
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

  def evaluation_criterion
    @evaluation_criterion ||= EvaluationCriterion.find_by(id: id)
  end

  def course
    evaluation_criterion&.course
  end
end
