class EvaluationCriterion < ApplicationRecord
  has_many :target_evaluation_criteria, dependent: :restrict_with_error
  has_many :targets, through: :target_evaluation_criteria
  has_many :timeline_event_grades, dependent: :restrict_with_error

  belongs_to :course

  validates :name, presence: true, uniqueness: { scope: %i[course_id max_grade pass_grade] }
  validates :description, presence: true
  validates :course, presence: true

  def display_name
    name + ' | ' + course.name
  end
end
