class AddQuizQuestionTypeToAnswerOption < ActiveRecord::Migration[5.1]
  def change
    add_column :answer_options, :quiz_question_type, :string
  end
end
