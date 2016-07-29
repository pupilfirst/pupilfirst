class CourseModule < ActiveRecord::Base
  has_many :quiz_questions

  has_many :quiz_attempts
  has_many :mooc_students, through: :quiz_attempts

  has_many :module_chapters
  accepts_nested_attributes_for :module_chapters, allow_destroy: true

  validates_presence_of :name, :module_number
  validates_uniqueness_of :module_number

  def self.valid_module_numbers
    CourseModule.all.pluck(:module_number)
  end

  def chapters_count
    module_chapters.maximum(:chapter_number)
  end
end
