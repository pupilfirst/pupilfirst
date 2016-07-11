class CourseChapter < ActiveRecord::Base
  has_many :quiz_questions
end
