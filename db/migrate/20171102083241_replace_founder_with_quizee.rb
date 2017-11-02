class ReplaceFounderWithQuizee < ActiveRecord::Migration[5.1]
  def change
    rename_column :english_quiz_submissions, :founder_id, :quizee_id
    add_column :english_quiz_submissions, :quizee_type, :string
  end
end
