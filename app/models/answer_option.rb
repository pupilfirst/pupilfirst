class AnswerOption < ApplicationRecord
  belongs_to :quiz_question, polymorphic: true

  validates :value, presence: true
end
