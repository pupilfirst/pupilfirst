class CourseChapter < ActiveRecord::Base
  has_many :quiz_questions

  has_many :quiz_attempts
  has_many :mooc_students, through: :quiz_attempts

  has_many :chapter_sections
  accepts_nested_attributes_for :chapter_sections

  validates_presence_of :name, :chapter_number, :sections_count
  validates_uniqueness_of :chapter_number

  def self.valid_chapter_numbers
    CourseChapter.all.pluck(:chapter_number)
  end
end
