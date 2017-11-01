class EnglishQuizSubmission < ApplicationRecord
  belongs_to :english_quiz_question
  belongs_to :founder
  belongs_to :answer_option
end
