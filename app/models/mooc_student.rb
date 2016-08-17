class MoocStudent < ActiveRecord::Base
  belongs_to :university
  belongs_to :user

  has_many :quiz_attempts
  has_many :course_modules, through: :quiz_attempts

  serialize :completed_chapters, Array

  def self.valid_semester_values
    %w(I II III IV V VI VII VIII Graduated Other)
  end

  def score
    # rubocop: disable SingleLineBlockParams
    CourseModule.with_quiz.inject(0.0) { |sum, course_module| sum + score_for_module(course_module) } / CourseModule.with_quiz.count
    # rubocop: enable SingleLineBlockParams
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
    completed_chapters.count { |c| c[0] == course_module.module_number } == course_module.chapters_count
  end

  def completed_quiz?(course_module)
    !course_module.quiz? || quiz_attempts.where(course_module: course_module).present?
  end

  def completed_module?(course_module)
    completed_all_chapters?(course_module) && completed_quiz?(course_module)
  end
end
