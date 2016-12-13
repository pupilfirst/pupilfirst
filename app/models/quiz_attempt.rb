class QuizAttempt < ApplicationRecord
  belongs_to :course_module
  belongs_to :mooc_student

  validates :course_module_id, presence: true
  validates :mooc_student_id, presence: true
  validates :score, presence: true
end
