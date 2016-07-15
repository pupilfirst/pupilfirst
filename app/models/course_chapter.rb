class CourseChapter < ActiveRecord::Base
  has_many :quiz_questions

  validates_presence_of :name, :chapter_number, :sections_count
  validates_uniqueness_of :chapter_number

  def self.valid_chapter_numbers
    CourseChapter.all.pluck(:chapter_number)
  end
end
