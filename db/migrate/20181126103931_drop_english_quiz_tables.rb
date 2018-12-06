class DropEnglishQuizTables < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :english_quiz_submissions, :answer_options
    remove_foreign_key :english_quiz_submissions, :english_quiz_questions
    drop_table :english_quiz_questions
    drop_table :english_quiz_submissions
    drop_table :answer_options
  end

  def down
    create_table :english_quiz_questions do |t|
      t.string :question
      t.text :explanation
      t.timestamps
      t.date "posted_on"
    end
    create_table :english_quiz_submissions  do |t|
      t.bigint :english_quiz_question_id, index: true
      t.bigint :quizee_id, index: true
      t.bigint :answer_option_id, index: true
      t.timestamps
      t.string :quizee_type
    end
    create_table :answer_options do |t|
      t.timestamps
      t.integer :quiz_question_id, index: true
      t.boolean :correct_answer, default: false
      t.string :value
      t.text :hint_text
      t.string :quiz_question_type
    end
    add_foreign_key :english_quiz_submissions,:answer_options
    add_foreign_key :english_quiz_submissions, :english_quiz_questions
  end
end

