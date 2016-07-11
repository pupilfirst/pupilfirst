class AddCourseChapterIdToQuizQuestion < ActiveRecord::Migration
  def change
    add_column :quiz_questions, :course_chapter_id, :integer
    add_index :quiz_questions, :course_chapter_id
  end
end
