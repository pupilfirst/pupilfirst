class CreateEnglishQuizQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :english_quiz_questions do |t|
      t.string :question
      t.text :explanation

      t.timestamps
    end
  end
end
