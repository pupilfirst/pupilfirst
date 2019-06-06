class AnswerOption < ApplicationRecord
  belongs_to :quiz_question
  has_one :quiz, through: :quiz_question
  validates :value, presence: true
end
