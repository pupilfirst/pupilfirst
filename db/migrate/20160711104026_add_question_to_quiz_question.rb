class AddQuestionToQuizQuestion < ActiveRecord::Migration
  def change
    add_column :quiz_questions, :question, :text
  end
end
