class RemoveQuestionNumberFromQuizQuestions < ActiveRecord::Migration
  def change
    remove_column :quiz_questions, :question_number, :integer
  end
end
