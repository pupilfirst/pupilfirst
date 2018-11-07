class EvaluationCriterion < ApplicationRecord
  has_many :target_evaluation_criteria, dependent: :restrict_with_error
  has_many :targets, through: :target_evaluation_criteria
  belongs_to :school

  validates :name, presence: true
  validates :description, presence: true
  validates :school, presence: true

  def display_name
    name
  end
end
