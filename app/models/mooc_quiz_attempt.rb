class MoocQuizAttempt < ApplicationRecord
  belongs_to :course_module
  belongs_to :mooc_student

  validates :score, presence: true
end
