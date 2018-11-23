class EvaluationCriterion < ApplicationRecord
  has_many :target_evaluation_criteria, dependent: :restrict_with_error
  has_many :targets, through: :target_evaluation_criteria
  belongs_to :course

  validates :name, presence: true
  validates :description, presence: true
  validates :course, presence: true

  def display_name
    name + ' | ' + course.name
  end
end
