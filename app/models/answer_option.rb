class AnswerOption < ApplicationRecord
  belongs_to :quiz_question

  validates_presence_of :value
end
