class UpdateQuizQuestionReferenceFromQuizzesToQuiz < ActiveRecord::Migration[5.2]
  def change
    remove_reference :quiz_questions,:quizzes, foreign_key: true
    add_reference :quiz_questions,:quiz, foreign_key: true
  end
end
