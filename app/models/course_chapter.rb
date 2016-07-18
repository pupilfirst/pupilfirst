class CourseChapter < ActiveRecord::Base
  has_many :quiz_questions
  accepts_nested_attributes_for :quiz_questions, allow_destroy: true

  validates_presence_of :name, :chapter_number, :sections_count
  validates_uniqueness_of :chapter_number

  def self.valid_chapter_numbers
    CourseChapter.all.pluck(:chapter_number)
  end
end
