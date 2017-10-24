class AnswerOption < ApplicationRecord
  belongs_to :quiz_question, polymorphic: true

  validates :value, presence: true
  validates :quiz_question_id, uniqueness: { scope: [:quiz_question_type] }
end
