class QuizAttempt < ActiveRecord::Base
  belongs_to :course_module
  belongs_to :mooc_student

  validates_presence_of :course_module_id, :mooc_student_id, :score
end
