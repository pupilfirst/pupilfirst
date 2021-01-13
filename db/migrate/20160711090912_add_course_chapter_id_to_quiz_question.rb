class AddCourseChapterIdToQuizQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :quiz_questions, :course_chapter_id, :integer
    add_index :quiz_questions, :course_chapter_id
  end
end
