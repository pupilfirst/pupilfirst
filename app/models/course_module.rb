class CourseModule < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  has_many :quiz_questions

  has_many :quiz_attempts
  has_many :mooc_students, through: :quiz_attempts

  has_many :module_chapters
  accepts_nested_attributes_for :module_chapters, allow_destroy: true

  validates_presence_of :name, :module_number, :publish_at
  validates_uniqueness_of :module_number, :name

  def self.valid_module_numbers
    CourseModule.all.pluck(:module_number)
  end

  def self.last_module
    CourseModule.find_by_module_number CourseModule.all.maximum(:module_number)
  end

  def chapters_count
    module_chapters.maximum(:chapter_number)
  end

  def published?
    publish_at && publish_at < Time.now
  end

  scope :published, -> { where('publish_at < ?', Time.now) }

  def quiz?
    quiz_questions.any?
  end

  def self.with_quiz
    CourseModule.select(&:quiz?)
  end
end
