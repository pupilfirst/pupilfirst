class QuizAttempt < ActiveRecord::Base
  belongs_to :course_chapter
  belongs_to :mooc_student

  validates_presence_of :course_chapter_id, :mooc_student_id, :score
end
