class Quiz < ApplicationRecord
  belongs_to :target
  has_many :quiz_questions, dependent: :restrict_with_error
  has_many :answer_options, through: :quiz_questions

  validates :title, presence: true
end
