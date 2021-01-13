class AddQuestionNumberToQuizQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :quiz_questions, :question_number, :integer
    add_index :quiz_questions, :question_number
  end
end
