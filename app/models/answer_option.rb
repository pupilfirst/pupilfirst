class AnswerOption < ApplicationRecord
  belongs_to :quiz_question, polymorphic: true, inverse_of: :answer_options

  validates :value, presence: true
end
