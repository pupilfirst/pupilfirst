class AnswerOption < ApplicationRecord
  belongs_to :quiz_question

  validates :value, presence: true
end
