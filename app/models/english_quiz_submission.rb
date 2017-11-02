class EnglishQuizSubmission < ApplicationRecord
  belongs_to :english_quiz_question
  belongs_to :quizee, polymorphic: true
  belongs_to :answer_option
end
