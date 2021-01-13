class RemoveQuestionNumberFromQuizQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column :quiz_questions, :question_number, :integer
  end
end
