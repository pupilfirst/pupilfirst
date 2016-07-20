class CreateQuizAttempts < ActiveRecord::Migration
  def change
    create_table :quiz_attempts do |t|
      t.integer :course_chapter_id
      t.string :mooc_student_id
      t.datetime :taken_at
      t.float :score
      t.integer :total_questions
      t.integer :attempted_questions

      t.timestamps null: false
    end
    add_index :quiz_attempts, :course_chapter_id
    add_index :quiz_attempts, :mooc_student_id
  end
end
