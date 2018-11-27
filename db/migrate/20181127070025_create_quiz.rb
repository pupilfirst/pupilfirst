class CreateQuiz < ActiveRecord::Migration[5.2]
  def change
    create_table :quiz_questions do |t|
      t.string :question
      t.text :description

      t.timestamps
    end

    create_table :answer_options do |t|
      t.references :quiz_question, foreign_key: true
      t.string :value
      t.boolean :correct_answer, default: false
      t.text :hint

      t.timestamps
    end
  end
end
