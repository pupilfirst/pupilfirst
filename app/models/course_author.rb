class CourseAuthor < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates_with RateLimitValidator, limit: 100, scope: :course_id
end
