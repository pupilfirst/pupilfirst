class CreateQuizTables < ActiveRecord::Migration[5.2]
  def change
    create_table :quizzes do |t|
      t.string :title
      t.references :target, foreign_key: true
      t.timestamps
    end

    create_table :quiz_questions do |t|
      t.string :question
      t.text :description
      t.references :quiz, foreign_key: true

      t.timestamps
    end

    create_table :answer_options do |t|
      t.references :quiz_question, foreign_key: true
      t.string :value
      t.text :hint

      t.timestamps
    end

    add_reference(:quiz_questions, :correct_answer, foreign_key: {to_table: :answer_options})
  end
end
