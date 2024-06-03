class CoursesCourseCategory < ApplicationRecord
  belongs_to :course
  belongs_to :course_category
end
