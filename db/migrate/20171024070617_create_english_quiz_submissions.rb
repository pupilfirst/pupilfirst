class CreateEnglishQuizSubmissions < ActiveRecord::Migration[5.1]
  def change
    create_table :english_quiz_submissions do |t|
      t.references :english_quiz_question, foreign_key: true
      t.references :founder, foreign_key: true
      t.references :answer_option, foreign_key: true

      t.timestamps
    end
  end
end
