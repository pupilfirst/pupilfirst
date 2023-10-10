class Assignment < ApplicationRecord
  belongs_to :target
  has_one :quiz, dependent: :restrict_with_error
  has_many :assignment_prerequisites, dependent: :destroy
  has_many :prerequisite_assignments, through: :assignment_prerequisites
  has_many :assignment_evaluation_criteria, dependent: :destroy
  has_many :evaluation_criteria, through: :assignment_evaluation_criteria
end
