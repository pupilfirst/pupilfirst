class AddQuestionToQuizQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :quiz_questions, :question, :text
  end
end
