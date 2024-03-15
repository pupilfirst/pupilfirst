class EvaluationCriterion < ApplicationRecord
  has_many :assignments_evaluation_criteria, dependent: :restrict_with_error
  has_many :assignments, through: :assignments_evaluation_criteria
  has_many :timeline_event_grades, dependent: :restrict_with_error

  belongs_to :course

  validates :max_grade, presence: true, numericality: { greater_than: 0 }

  validates :grade_labels, presence: true
  validate :grade_labels_must_match_grades

  validates :name,
            presence: true,
            uniqueness: {
              scope: %i[course_id max_grade]
            }

  validates_with RateLimitValidator, limit: 100, scope: :course_id

  def display_name
    name + " #{max_grade}"
  end

  private

  def grade_labels_must_match_grades
    return if grade_labels.pluck("grade") == [*1..max_grade]

    errors.add(:grade_labels, "do not match available grades")
  end
end
