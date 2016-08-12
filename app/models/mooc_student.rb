class MoocStudent < ActiveRecord::Base
  belongs_to :university
  belongs_to :user

  has_many :quiz_attempts
  has_many :course_modules, through: :quiz_attempts

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
end
