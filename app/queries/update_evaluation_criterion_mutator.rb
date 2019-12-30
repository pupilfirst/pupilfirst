class UpdateEvaluationCriterionMutator < ApplicationQuery
  property :id
  property :name, validates: { presence: true, length: { minimum: 1, maximum: 50 } }
  property :description, validates: { presence: true, length: { minimum: 1, maximum: 150 } }
  property :grades_and_labels, validates: { presence: true }

  validate :valid_ec_id
  validate :correct_grades_and_labels

  def valid_ec_id
    return if evaluation_criterion.present?

    raise "UpdateEvaluationCriterionMutator received non-existent evaluation criterion ID #{id}"
  end

  def correct_grades_and_labels
    return if evaluation_criterion.max_grade == (grade_labels.values - [""]).count

    raise "UpdateEvaluationCriterionMutator received invalid grades and labels #{grades_and_labels}"
  end

  def update_evaluation_criterion
    evaluation_criterion.update!(
      name: name,
      description: description,
      grade_labels: grade_labels
    )
    evaluation_criterion
  end

  private

  def grade_labels
    grades_and_labels.map do |grades_and_label|
      grade = grades_and_label[:grade]
      label = grades_and_label[:label].strip
      [grade.to_s, label.presence || grade.humanize]
    end.to_h
  end

  def evaluation_criterion
    @evaluation_criterion ||= EvaluationCriterion.find_by(id: id)
  end

  def authorized?
    current_school_admin.present? && evaluation_criterion.course.in?(current_school.courses)
  end
end
