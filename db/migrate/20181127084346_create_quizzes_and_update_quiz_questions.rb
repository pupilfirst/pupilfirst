class CreateQuizzesAndUpdateQuizQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :quizzes do |t|
      t.string :title
      t.references :target, foreign_key: true
      t.timestamps
    end
    add_reference :quiz_questions,:quizzes, foreign_key: true
  end
end
