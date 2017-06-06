class MoocStudent < ApplicationRecord
  belongs_to :college, optional: true
  belongs_to :user

  has_many :quiz_attempts
  has_many :course_modules, through: :quiz_attempts

  serialize :completed_chapters, Array

  scope :completed_quiz, ->(course_module) { MoocStudent.joins(:quiz_attempts).where(quiz_attempts: { course_module_id: course_module.id }).distinct }

  def self.valid_semester_values
    %w[I II III IV V VI VII VIII Graduated Other]
  end

  def score
    CourseModule.with_quiz.inject(0.0) { |sum, course_module| sum + score_for_module(course_module) } / CourseModule.with_quiz.count
  end

  def score_for_module(course_module)
    quiz_attempts.where(course_module: course_module).order('created_at DESC').first&.score.to_i
  end

  def add_completed_chapter(chapter)
    self.completed_chapters |= [[chapter.course_module.module_number, chapter.chapter_number]]
    save!
  end

  def completed_chapter?(chapter)
    [chapter.course_module.module_number, chapter.chapter_number].in? self.completed_chapters
  end

  def completed_all_chapters?(course_module)
    course_module.chapters_count == completed_chapters.count { |c| c[0] == course_module.module_number }
  end

  def completed_quiz?(course_module)
    !course_module.quiz? || quiz_attempts.where(course_module: course_module).present?
  end

  def completed_module?(course_module)
    completed_all_chapters?(course_module) && completed_quiz?(course_module)
  end

  def started_course?
    completed_chapters.present?
  end

  def college_name
    college&.name || college_text
  end
end
