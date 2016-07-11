class CourseChapter < ActiveRecord::Base
  has_many :quiz_questions

  validates_presence_of :name
end
