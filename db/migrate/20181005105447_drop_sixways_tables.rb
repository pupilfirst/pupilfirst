class DropSixwaysTables < ActiveRecord::Migration[5.1]
  def up
    drop_table :mooc_quiz_attempts
    drop_table :mooc_quiz_questions
    drop_table :module_chapters
    drop_table :course_modules
    drop_table :mooc_students
  end

  def down
    create_table :mooc_students do |t|
      t.string :email
      t.string :name
      t.string :college_text
      t.string :semester
      t.string :gender
      t.references :user
      t.string :phone
      t.text :completed_chapters
      t.references :college, index: true
      t.timestamps
    end

    create_table :course_modules do |t|
      t.string :name
      t.integer :module_number
      t.string :slug, index: true
      t.datetime :publish_at
      t.timestamps
    end

    create_table :module_chapters do |t|
      t.references :course_module, index: true
      t.string :name
      t.integer :chapter_number
      t.text :links
      t.string :slug, index: true
      t.timestamps
    end

    create_table :mooc_quiz_questions do |t|
      t.references :course_module, index: true
      t.text :question
      t.timestamps
    end

    create_table :mooc_quiz_attempts do |t|
      t.references :course_module, index: true
      t.references :mooc_student, index: true
      t.datetime :taken_at
      t.float :score
      t.integer :total_questions
      t.integer :attempted_questions
      t.timestamps
    end
  end
end
