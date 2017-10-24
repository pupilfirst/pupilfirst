class RenameQuizQuestionToMoocQuizQuestion < ActiveRecord::Migration[5.1]
  def change
    rename_table :quiz_questions, :mooc_quiz_questions
  end
end
