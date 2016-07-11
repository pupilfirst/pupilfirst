class AddQuizQuestionIdToAnswerOption < ActiveRecord::Migration
  def change
    add_column :answer_options, :quiz_question_id, :integer
    add_index :answer_options, :quiz_question_id
  end
end
