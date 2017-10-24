class AnswerOption < ApplicationRecord
  belongs_to :mooc_quiz_question

  validates :value, presence: true
end
